create table public.approved_teachers(email text primary key check(email=lower(trim(email)) and email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'),name text not null check(length(trim(name)) between 1 and 120));
create table public.representative_applications(
 id uuid primary key default gen_random_uuid(),user_id uuid not null references public.profiles on delete cascade,
 applicant_name text not null,club_name text not null check(length(trim(club_name)) between 2 and 120),
 description text not null check(length(trim(description)) between 10 and 1000),teacher_email text not null,
 status text not null default 'pending_teacher' check(status in ('pending_teacher','teacher_approved','teacher_rejected','approved','rejected')),
 created_at timestamptz not null default now(),teacher_reviewed_at timestamptz,owner_reviewed_at timestamptz,organization_id uuid references public.organizations on delete restrict
);
create unique index one_open_club_application on public.representative_applications(user_id,lower(club_name)) where status in ('pending_teacher','teacher_approved');
create index applications_user on public.representative_applications(user_id,created_at);
create index applications_status on public.representative_applications(status,created_at);
create table public.teacher_approval_tokens(application_id uuid primary key references public.representative_applications on delete cascade,token_hash text not null unique,expires_at timestamptz not null,used_at timestamptz,last_sent_at timestamptz not null default now());
create table public.application_email_attempts(application_id uuid primary key references public.representative_applications on delete cascade,requested_at timestamptz not null default now());
create table public.application_notification_outbox(application_id uuid primary key references public.representative_applications on delete cascade,created_at timestamptz not null default now(),sent_at timestamptz);
alter table public.approved_teachers enable row level security;
alter table public.representative_applications enable row level security;
alter table public.teacher_approval_tokens enable row level security;
alter table public.application_email_attempts enable row level security;
alter table public.application_notification_outbox enable row level security;
revoke all on public.approved_teachers,public.representative_applications,public.teacher_approval_tokens from anon,authenticated;
grant select,insert,update,delete on public.approved_teachers to authenticated;
grant select on public.representative_applications to authenticated;
grant all on public.approved_teachers,public.representative_applications,public.teacher_approval_tokens to service_role;
revoke all on public.application_email_attempts,public.application_notification_outbox from anon,authenticated;
grant all on public.application_email_attempts,public.application_notification_outbox to service_role;
create policy teachers_owner on public.approved_teachers for all to authenticated using(public.is_owner()) with check(public.is_owner());
create policy applications_read on public.representative_applications for select to authenticated using(public.is_active() and (user_id=auth.uid() or public.is_owner()));
create function public.submit_representative_application(club text,brief text,teacher text) returns uuid language plpgsql security definer set search_path='' as $$
declare application uuid; person public.profiles;
begin
 if not public.is_active() then raise exception 'Active account required';end if;
 select * into person from public.profiles where id=auth.uid();
 if not exists(select 1 from auth.users where id=auth.uid() and email_confirmed_at is not null) then raise exception 'Confirm your own email first';end if;
 if not exists(select 1 from public.approved_teachers where email=lower(trim(teacher))) then raise exception 'This teacher email is not authorized. Ask the Owner to add your teacher.';end if;
 -- Serialize submissions by this user and cap requests to avoid email flooding.
 perform pg_advisory_xact_lock(hashtextextended(auth.uid()::text,0));
 perform pg_advisory_xact_lock(hashtextextended(lower(trim(teacher)),1));
 if (select count(*) from public.representative_applications where user_id=auth.uid() and created_at>now()-interval '1 day')>=3 then raise exception 'You can submit up to three applications per day';end if;
 if (select count(*) from public.representative_applications where teacher_email=lower(trim(teacher)) and created_at>now()-interval '1 hour')>=10 then raise exception 'This teacher has received too many requests recently. Try later.';end if;
 insert into public.representative_applications(user_id,applicant_name,club_name,description,teacher_email) values(auth.uid(),person.name,trim(club),trim(brief),lower(trim(teacher))) returning id into application;
 return application;
end$$;
create function public.review_teacher_application(hash text,approve boolean) returns void language plpgsql security definer set search_path='' as $$
declare token public.teacher_approval_tokens; application public.representative_applications;
begin
 select * into token from public.teacher_approval_tokens where token_hash=hash for update;
 if not found or token.used_at is not null or token.expires_at<=now() then raise exception 'This approval link is expired or already used';end if;
 select * into application from public.representative_applications where id=token.application_id for update;
 if application.status<>'pending_teacher' or not exists(select 1 from public.approved_teachers where email=application.teacher_email) then raise exception 'This application is no longer eligible for teacher review';end if;
 update public.teacher_approval_tokens set used_at=now() where application_id=application.id;
 update public.representative_applications set status=case when approve then 'teacher_approved' else 'teacher_rejected' end,teacher_reviewed_at=now() where id=application.id;
 if approve then insert into public.application_notification_outbox(application_id) values(application.id) on conflict do nothing;end if;
end$$;
create function public.finalize_representative_application(application_id uuid,approve boolean,organization uuid default null) returns void language plpgsql security definer set search_path='' as $$
declare application public.representative_applications; chosen uuid;
begin
 if not public.is_owner() then raise exception 'Owner required';end if;
 select * into application from public.representative_applications where id=application_id for update;
 if not found or application.status<>'teacher_approved' then raise exception 'Teacher approval is required first';end if;
 if approve then
  if not exists(select 1 from public.approved_teachers where email=application.teacher_email) then raise exception 'Approving teacher is no longer authorized';end if;
  if not exists(select 1 from public.profiles where id=application.user_id and active) then raise exception 'Applicant account is disabled';end if;
  if exists(select 1 from public.user_roles where user_id=application.user_id and role='Owner') then raise exception 'Cannot modify Owner';end if;
  chosen=organization;
  if chosen is null then
   insert into public.organizations(name,description) values(application.club_name,application.description) returning id into chosen;
  elsif not exists(select 1 from public.organizations where id=chosen) then raise exception 'Organization does not exist';end if;
  update public.user_roles set role='Representative' where user_id=application.user_id;
  insert into public.organization_representatives(user_id,organization_id) values(application.user_id,chosen) on conflict do nothing;
 end if;
 update public.representative_applications set status=case when approve then 'approved' else 'rejected' end,owner_reviewed_at=now(),organization_id=chosen where id=application_id;
end$$;
revoke all on function public.submit_representative_application(text,text,text),public.review_teacher_application(text,boolean),public.finalize_representative_application(uuid,boolean,uuid) from public,anon,authenticated;
grant execute on function public.submit_representative_application(text,text,text),public.finalize_representative_application(uuid,boolean,uuid) to authenticated;
grant execute on function public.review_teacher_application(text,boolean) to service_role;
create function public.reserve_teacher_email(application uuid) returns boolean language plpgsql security definer set search_path='' as $$
declare touched integer;
begin
 insert into public.application_email_attempts(application_id) values(application)
 on conflict(application_id) do update set requested_at=now() where public.application_email_attempts.requested_at<=now()-interval '5 minutes';
 get diagnostics touched=row_count;return touched=1;
end$$;
revoke all on function public.reserve_teacher_email(uuid) from public,anon,authenticated;
grant execute on function public.reserve_teacher_email(uuid) to service_role;

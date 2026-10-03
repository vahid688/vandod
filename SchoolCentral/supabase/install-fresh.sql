-- SchoolCentral: fresh-project installation only.
begin;
do $$ begin if to_regclass('public.user_roles') is not null then raise exception 'SchoolCentral already exists. Apply pending migrations instead.';end if;end $$;
create extension if not exists pgcrypto;
create type public.school_role as enum ('Student','Representative','Owner');
create table public.profiles(id uuid primary key references auth.users on delete cascade,name text not null default '' check(length(name)<=120),email text not null,active boolean not null default true,created_at timestamptz not null default now());
create table public.user_roles(user_id uuid primary key references public.profiles on delete cascade,role public.school_role not null default 'Student');
create unique index sole_owner on public.user_roles(role) where role='Owner';
create table public.categories(id uuid primary key default gen_random_uuid(),name text not null unique check(length(name) between 1 and 80),color text not null default '#227869' check(color ~ '^#[0-9a-fA-F]{6}$'));
create table public.organizations(id uuid primary key default gen_random_uuid(),name text not null unique check(length(name) between 1 and 120),description text not null default '',created_at timestamptz not null default now());
create table public.organization_representatives(user_id uuid references public.profiles on delete cascade,organization_id uuid references public.organizations on delete cascade,primary key(user_id,organization_id));
create index assignment_org on public.organization_representatives(organization_id);
create table public.events(id uuid primary key default gen_random_uuid(),organization_id uuid not null references public.organizations on delete restrict,category_id uuid not null references public.categories on delete restrict,title text not null check(length(trim(title)) between 1 and 180),description text not null default '',starts_at timestamptz not null,ends_at timestamptz not null,all_day boolean not null default false,location text not null default '',external_url text not null default '' check(external_url='' or external_url ~ '^https?://'),status text not null default 'draft' check(status in ('draft','published')),created_by uuid not null references public.profiles,updated_by uuid not null references public.profiles,created_at timestamptz not null default now(),updated_at timestamptz not null default now(),check(ends_at>=starts_at));
create index events_start on public.events(starts_at);
create index events_org on public.events(organization_id,starts_at);
create index events_category on public.events(category_id,starts_at);
create table public.favorites(user_id uuid references public.profiles on delete cascade,event_id uuid references public.events on delete cascade,primary key(user_id,event_id));
create index favorites_event on public.favorites(event_id);
create table public.settings(id boolean primary key default true check(id),school_name text not null default 'SchoolCentral',timezone text not null default 'America/Toronto');
insert into public.settings default values;
create function public.is_active() returns boolean language sql stable security definer set search_path='' as $$select exists(select 1 from public.profiles where id=auth.uid() and active)$$;
create function public.is_owner() returns boolean language sql stable security definer set search_path='' as $$select public.is_active() and exists(select 1 from public.user_roles where user_id=auth.uid() and role='Owner')$$;
create function public.can_manage(org uuid) returns boolean language sql stable security definer set search_path='' as $$select public.is_owner() or (public.is_active() and exists(select 1 from public.user_roles r join public.organization_representatives a on a.user_id=r.user_id where r.user_id=auth.uid() and r.role='Representative' and a.organization_id=org))$$;
create function public.new_user() returns trigger language plpgsql security definer set search_path='' as $$begin insert into public.profiles(id,name,email) values(new.id,left(coalesce(new.raw_user_meta_data->>'name','Student'),120),new.email);insert into public.user_roles(user_id) values(new.id);return new;end$$;
create trigger new_user after insert on auth.users for each row execute function public.new_user();
create function public.event_audit() returns trigger language plpgsql set search_path='' as $$begin if TG_OP='INSERT' then new.created_by=auth.uid();new.created_at=now();else new.created_by=old.created_by;new.created_at=old.created_at;end if;new.updated_by=auth.uid();new.updated_at=now();return new;end$$;
create trigger event_audit before insert or update on public.events for each row execute function public.event_audit();
create function public.assign_representative(target uuid,orgs uuid[]) returns void language plpgsql security definer set search_path='' as $$begin if not public.is_owner() then raise exception 'Owner required';end if;if exists(select 1 from public.user_roles where user_id=target and role='Owner') then raise exception 'Cannot modify Owner';end if;if not exists(select 1 from public.profiles where id=target and active) then raise exception 'Active user required';end if;update public.user_roles set role=case when cardinality(orgs)>0 then 'Representative'::public.school_role else 'Student'::public.school_role end where user_id=target;delete from public.organization_representatives where user_id=target;insert into public.organization_representatives(user_id,organization_id) select target,unnest(orgs);end$$;
create function public.protect_owner() returns trigger language plpgsql set search_path='' as $$begin if exists(select 1 from public.user_roles where user_id=old.id and role='Owner') and not new.active then raise exception 'Owner cannot be disabled';end if;return new;end$$;
create trigger protect_owner before update on public.profiles for each row execute function public.protect_owner();
alter table public.profiles enable row level security;
alter table public.user_roles enable row level security;
alter table public.categories enable row level security;
alter table public.organizations enable row level security;
alter table public.organization_representatives enable row level security;
alter table public.events enable row level security;
alter table public.favorites enable row level security;
alter table public.settings enable row level security;
create policy profiles_read on public.profiles for select to authenticated using(id=auth.uid() or public.is_owner());
create policy profiles_owner_update on public.profiles for update to authenticated using(public.is_owner()) with check(public.is_owner());
create policy roles_read on public.user_roles for select to authenticated using(user_id=auth.uid() or public.is_owner());
create policy assignments_read on public.organization_representatives for select to authenticated using(user_id=auth.uid() or public.is_owner());
create policy organizations_read on public.organizations for select to authenticated using(public.is_active());
create policy organizations_owner on public.organizations for all to authenticated using(public.is_owner()) with check(public.is_owner());
create policy categories_read on public.categories for select to authenticated using(public.is_active());
create policy categories_owner on public.categories for all to authenticated using(public.is_owner()) with check(public.is_owner());
create policy events_read on public.events for select to authenticated using(public.is_active() and (status='published' or public.can_manage(organization_id)));
create policy events_insert on public.events for insert to authenticated with check(public.can_manage(organization_id));
create policy events_update on public.events for update to authenticated using(public.can_manage(organization_id)) with check(public.can_manage(organization_id));
create policy events_delete on public.events for delete to authenticated using(public.can_manage(organization_id));
create policy favorites_read on public.favorites for select to authenticated using(public.is_active() and user_id=auth.uid());
create policy favorites_insert on public.favorites for insert to authenticated with check(public.is_active() and user_id=auth.uid() and exists(select 1 from public.events where id=event_id and status='published'));
create policy favorites_delete on public.favorites for delete to authenticated using(user_id=auth.uid());
create policy settings_read on public.settings for select to authenticated using(public.is_active());
create policy settings_owner on public.settings for update to authenticated using(public.is_owner()) with check(public.is_owner());
revoke all on public.profiles,public.user_roles,public.organization_representatives,public.events,public.categories,public.organizations,public.favorites,public.settings from anon,authenticated;
grant select on public.profiles,public.user_roles,public.organization_representatives,public.settings to authenticated;
grant update(name,active) on public.profiles to authenticated;
grant update(school_name,timezone) on public.settings to authenticated;
grant select,insert,update,delete on public.events,public.categories,public.organizations,public.favorites to authenticated;
revoke all on function public.assign_representative(uuid,uuid[]),public.new_user(),public.event_audit(),public.protect_owner(),public.is_active(),public.is_owner(),public.can_manage(uuid) from public;
grant execute on function public.assign_representative(uuid,uuid[]),public.is_active(),public.is_owner(),public.can_manage(uuid) to authenticated;
-- Realtime sends only rows visible under SELECT RLS. Refresh fallback handles deletes.
alter publication supabase_realtime add table public.events;


-- Update existing installations while preserving custom platform names.
alter table public.settings alter column school_name set default 'SchoolCentral';
update public.settings set school_name='SchoolCentral' where school_name='SchoolHub';

create table public.approved_teachers(email text primary key check(email=lower(trim(email)) and email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'),name text not null check(length(trim(name)) between 1 and 120));
create table public.representative_applications(
 id uuid primary key default gen_random_uuid(),user_id uuid not null references public.profiles on delete cascade,
 applicant_name text not null,club_name text not null check(length(trim(club_name)) between 2 and 120),
 description text not null check(length(trim(description)) between 10 and 1000),teacher_email text not null,
 status text not null default 'pending_teacher' check(status in ('pending_teacher','teacher_approved','teacher_rejected','approved','rejected','accepted')),
 created_at timestamptz not null default now(),teacher_reviewed_at timestamptz,owner_reviewed_at timestamptz,organization_id uuid references public.organizations on delete restrict
);
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
 -- Serialize submissions by this user and this teacher
 perform pg_advisory_xact_lock(hashtextextended(auth.uid()::text,0));
 perform pg_advisory_xact_lock(hashtextextended(lower(trim(teacher)),1));
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

-- Only the authorized teacher name/email directory becomes readable.
-- Owner-only write policies and server-side application validation are unchanged.
create policy teachers_directory_read on public.approved_teachers
for select to authenticated using ((select public.is_active()));

create table public.notification_preferences (
 user_id uuid primary key references public.profiles on delete cascade,
 email text not null check (length(email)<=254 and email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$'),
 reminders boolean not null default false,
 changes boolean not null default false
);
alter table public.notification_preferences enable row level security;
revoke all on public.notification_preferences from anon, authenticated;
grant select, insert, update on public.notification_preferences to authenticated;
grant all on public.notification_preferences to service_role;
create policy notification_read on public.notification_preferences for select to authenticated using(user_id=(select auth.uid()) and public.is_active());
create policy notification_insert on public.notification_preferences for insert to authenticated with check(user_id=(select auth.uid()) and public.is_active());
create policy notification_update on public.notification_preferences for update to authenticated using(user_id=(select auth.uid()) and public.is_active()) with check(user_id=(select auth.uid()) and public.is_active());

create table public.event_email_queue (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references public.profiles on delete cascade,
 event_id uuid not null,
 kind text not null check(kind in ('reminder','change','cancelled')),
 title text not null,
 starts_at timestamptz not null,
 location text not null,
 version timestamptz not null,
 sent_at timestamptz,
 unique(user_id,event_id,kind,version)
);
alter table public.event_email_queue enable row level security;
revoke all on public.event_email_queue from anon, authenticated;
grant all on public.event_email_queue to service_role;
create index event_email_pending on public.event_email_queue(sent_at) where sent_at is null;
create schema if not exists private;
create function private.queue_event_changes() returns trigger language plpgsql security definer set search_path='' as $$
begin
 if old.status <> 'published' then if TG_OP='DELETE' then return old; else return new; end if; end if;
 if TG_OP='UPDATE' then
  if (old.title,old.description,old.starts_at,old.ends_at,old.location,old.external_url,old.status,old.organization_id,old.category_id,old.all_day) is not distinct from (new.title,new.description,new.starts_at,new.ends_at,new.location,new.external_url,new.status,new.organization_id,new.category_id,new.all_day) then if TG_OP='DELETE' then return old; else return new; end if; end if;
 end if;
 insert into public.event_email_queue(user_id,event_id,kind,title,starts_at,location,version)
 select f.user_id,old.id,
 case when TG_OP='DELETE' then 'cancelled' when new.status='draft' then 'cancelled' else 'change' end,
 case when TG_OP='DELETE' then old.title else new.title end,
 case when TG_OP='DELETE' then old.starts_at else new.starts_at end,
 case when TG_OP='DELETE' then old.location else new.location end,clock_timestamp()
 from public.favorites f join public.notification_preferences p on p.user_id=f.user_id
 where f.event_id=old.id and p.changes;
 if TG_OP='DELETE' then return old; else return new; end if;
end $$;
revoke all on function private.queue_event_changes() from public,anon,authenticated;
create trigger event_change_emails before update or delete on public.events for each row execute function private.queue_event_changes();

alter table public.notification_preferences
 add column reminder_minutes integer not null default 1440
 check (reminder_minutes in (5,10,15,30,60,120,360,720,1440));

commit;

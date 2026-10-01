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

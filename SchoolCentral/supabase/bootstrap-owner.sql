-- Run as a trusted database administrator AFTER Vandod has signed up
-- and confirmed vnnamazi@gmail.com through Supabase Auth.
-- This refuses to replace another Owner or promote an unverified email.
begin;
do $$
declare owner_id uuid;
begin
 select id into strict owner_id from auth.users
 where lower(email)='vnnamazi@gmail.com' and email_confirmed_at is not null;
 if exists(select 1 from public.user_roles where role='Owner' and user_id<>owner_id) then
  raise exception 'Another Owner already exists; no changes were made';
 end if;
 if not exists(select 1 from public.profiles where id=owner_id and active) then
  raise exception 'An active, registered profile is required';
 end if;
 update public.profiles set name='Vandod Namazi' where id=owner_id;
 update public.user_roles set role='Owner' where user_id=owner_id;
 if not found then raise exception 'Student role record is missing';end if;
end $$;
commit;
select p.id,p.name,p.email,r.role
from public.profiles p join public.user_roles r on r.user_id=p.id
where r.role='Owner';

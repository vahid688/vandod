-- Update representative applications functions to remove daily/hourly limits
-- Run this in Supabase SQL Editor to fix the "You can submit up to three applications per day" error

-- Drop and recreate the submit_representative_application function without limits
create or replace function public.submit_representative_application(club text,brief text,teacher text) returns uuid language plpgsql security definer set search_path='' as $$
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

-- Drop the unique constraint that prevents duplicate club applications
drop index if exists public.one_open_club_application;

-- Verify changes
select 'Functions updated successfully' as status;

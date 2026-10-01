-- Trusted SQL Editor/local-only optional fixtures. No accounts are created.
do $$
declare owner_id uuid; row record;
begin
select user_id into owner_id from public.user_roles where role='Owner';
if owner_id is null then raise exception 'Bootstrap the verified sole Owner first';end if;
perform set_config('request.jwt.claim.sub',owner_id::text,true);
for row in select * from (values
 ('Robotics Club','Clubs','Robotics Club Meeting','Innovation Lab',0),
 ('Senior Jazz Band','Arts','Senior Jazz Band Rehearsal','Music Room',0),
 ('Varsity Basketball','Sports','Varsity Basketball Game','School Gym',1),
 ('Student Council','Leadership','Student Council Meeting','Room 112',2),
 ('Guidance Office','Academic','University Application Workshop','Library',3),
 ('Community Volunteers','Volunteer','Community Park Cleanup','Riverside Park',5)
) as fixtures(org,cat,title,location,offset_days)
loop
insert into public.events(organization_id,category_id,title,description,starts_at,ends_at,location,status,created_by,updated_by)
select o.id,c.id,row.title,'[DEMO] Join your school community. New members are welcome.',date_trunc('day',now())+make_interval(days=>row.offset_days,hours=>15),date_trunc('day',now())+make_interval(days=>row.offset_days,hours=>16),row.location,'published',owner_id,owner_id
from public.organizations o,public.categories c where o.name=row.org and c.name=row.cat
and not exists(select 1 from public.events where title=row.title and description like '[DEMO]%');
end loop;
end $$;

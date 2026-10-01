-- Run with psql -v ON_ERROR_STOP=1 on a fresh, disposable Supabase database.
-- All fixtures roll back. This script deliberately requires no existing Owner.
begin;
insert into auth.users(id,email,raw_user_meta_data) values
('10000000-0000-4000-8000-000000000001','owner@test.invalid','{"name":"Owner"}'),
('10000000-0000-4000-8000-000000000002','rep@test.invalid','{"name":"Rep","role":"Owner"}'),
('10000000-0000-4000-8000-000000000003','student@test.invalid','{"name":"Student","role":"Representative"}');
update public.user_roles set role='Owner' where user_id='10000000-0000-4000-8000-000000000001';
insert into public.organizations(id,name) values ('20000000-0000-4000-8000-000000000001','Test assigned'),('20000000-0000-4000-8000-000000000002','Test unrelated');
insert into public.categories(id,name) values ('30000000-0000-4000-8000-000000000001','Test category');
select set_config('request.jwt.claim.sub','10000000-0000-4000-8000-000000000001',true);
set local role authenticated;
select public.assign_representative('10000000-0000-4000-8000-000000000002',array['20000000-0000-4000-8000-000000000001'::uuid]);
insert into public.events(id,organization_id,category_id,title,starts_at,ends_at,status,created_by,updated_by) values
('40000000-0000-4000-8000-000000000001','20000000-0000-4000-8000-000000000001','30000000-0000-4000-8000-000000000001','Published',now(),now()+interval '1 hour','published','10000000-0000-4000-8000-000000000003','10000000-0000-4000-8000-000000000003'),
('40000000-0000-4000-8000-000000000002','20000000-0000-4000-8000-000000000002','30000000-0000-4000-8000-000000000001','Draft',now(),now()+interval '1 hour','draft','10000000-0000-4000-8000-000000000001','10000000-0000-4000-8000-000000000001');
do $$begin
if (select created_by from public.events where id='40000000-0000-4000-8000-000000000001')<>'10000000-0000-4000-8000-000000000001'::uuid then raise exception 'Audit spoofing allowed';end if;
begin perform public.assign_representative('10000000-0000-4000-8000-000000000001',array[]::uuid[]);raise exception 'Owner role was mutable';exception when raise_exception then if sqlerrm='Owner role was mutable' then raise;end if;end;
end$$;
select set_config('request.jwt.claim.sub','10000000-0000-4000-8000-000000000003',true);
do $$declare touched integer;begin
if (select role from public.user_roles where user_id=auth.uid())<>'Student' then raise exception 'Metadata promotion allowed';end if;
if exists(select 1 from public.events where status='draft') then raise exception 'Draft leaked';end if;
begin update public.user_roles set role='Owner' where user_id=auth.uid();raise exception 'Direct promotion allowed';exception when insufficient_privilege then null;end;
begin perform public.assign_representative(auth.uid(),array['20000000-0000-4000-8000-000000000001'::uuid]);raise exception 'Student RPC promotion allowed';exception when raise_exception then if sqlerrm='Student RPC promotion allowed' then raise;end if;end;
begin insert into public.events(organization_id,category_id,title,starts_at,ends_at,created_by,updated_by) values('20000000-0000-4000-8000-000000000001','30000000-0000-4000-8000-000000000001','Illegal',now(),now(),auth.uid(),auth.uid());raise exception 'Student event write allowed';exception when insufficient_privilege then null;end;
update public.events set title='Illegal edit' where id='40000000-0000-4000-8000-000000000001';get diagnostics touched=row_count;if touched<>0 then raise exception 'Student event update allowed';end if;
insert into public.favorites(user_id,event_id) values(auth.uid(),'40000000-0000-4000-8000-000000000001');
begin insert into public.favorites(user_id,event_id) values('10000000-0000-4000-8000-000000000002','40000000-0000-4000-8000-000000000001');raise exception 'Other user favorite allowed';exception when insufficient_privilege then null;end;
end$$;
select set_config('request.jwt.claim.sub','10000000-0000-4000-8000-000000000002',true);
do $$begin
if not public.can_manage('20000000-0000-4000-8000-000000000001') or public.can_manage('20000000-0000-4000-8000-000000000002') then raise exception 'Representative scope incorrect';end if;
update public.events set title='Rep edit' where id='40000000-0000-4000-8000-000000000001';
begin update public.events set organization_id='20000000-0000-4000-8000-000000000002' where id='40000000-0000-4000-8000-000000000001';raise exception 'Cross-org move allowed';exception when insufficient_privilege then null;end;
begin insert into public.events(organization_id,category_id,title,starts_at,ends_at,created_by,updated_by) values('20000000-0000-4000-8000-000000000002','30000000-0000-4000-8000-000000000001','Illegal rep',now(),now(),auth.uid(),auth.uid());raise exception 'Unassigned insert allowed';exception when insufficient_privilege then null;end;
end$$;
select set_config('request.jwt.claim.sub','10000000-0000-4000-8000-000000000001',true);
select public.assign_representative('10000000-0000-4000-8000-000000000002',array[]::uuid[]);
select set_config('request.jwt.claim.sub','10000000-0000-4000-8000-000000000002',true);
do $$begin if public.can_manage('20000000-0000-4000-8000-000000000001') then raise exception 'Revoked representative still allowed';end if;end$$;
reset role;
do $$begin begin update public.user_roles set role='Owner' where user_id='10000000-0000-4000-8000-000000000003';raise exception 'Second Owner allowed';exception when unique_violation then null;end;end$$;
set local role anon;
do $$begin begin perform 1 from public.events;raise exception 'Anonymous events readable';exception when insufficient_privilege then null;end;end$$;
reset role;
rollback;
select 'SchoolCentral authorization checks passed' as result;


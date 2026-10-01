-- Fresh disposable database with all migrations applied; run with ON_ERROR_STOP=1.
begin;
insert into auth.users(id,email,email_confirmed_at,raw_user_meta_data) values
('11000000-0000-4000-8000-000000000001','owner@app-test.invalid',now(),'{"name":"Owner"}'),
('11000000-0000-4000-8000-000000000002','student@app-test.invalid',now(),'{"name":"Student"}'),
('11000000-0000-4000-8000-000000000003','other@app-test.invalid',now(),'{"name":"Other"}');
update public.user_roles set role='Owner' where user_id='11000000-0000-4000-8000-000000000001';
insert into public.approved_teachers(email,name) values ('teacher@app-test.invalid','Authorized Teacher');
select set_config('request.jwt.claim.sub','11000000-0000-4000-8000-000000000002',true);
set local role authenticated;
select public.submit_representative_application('Test application club','A club for verified application security testing.','teacher@app-test.invalid');
do $$begin
if (select role from public.user_roles where user_id=auth.uid())<>'Student' then raise exception 'Submitting application promoted applicant';end if;
if not exists(select 1 from public.approved_teachers where email='teacher@app-test.invalid') then raise exception 'Active applicant cannot read authorized teacher directory';end if;
begin perform public.submit_representative_application('Fake club','A sufficiently long application.','unauthorized@app-test.invalid');raise exception 'Unauthorized teacher accepted';exception when raise_exception then if sqlerrm='Unauthorized teacher accepted' then raise;end if;end;
begin update public.representative_applications set status='teacher_approved';raise exception 'Applicant forged approval';exception when insufficient_privilege then null;end;
begin perform public.review_teacher_application('fake',true);raise exception 'Applicant can review teacher tokens';exception when insufficient_privilege then null;end;
begin insert into public.approved_teachers(email,name) values ('fake@app-test.invalid','Fake');raise exception 'Applicant authorized teacher';exception when insufficient_privilege then null;end;
end$$;
select set_config('request.jwt.claim.sub','11000000-0000-4000-8000-000000000003',true);
do $$begin if exists(select 1 from public.representative_applications) then raise exception 'Another student can read applications';end if;end$$;
select set_config('request.jwt.claim.sub','11000000-0000-4000-8000-000000000001',true);
do $$declare app uuid;begin
select id into app from public.representative_applications where club_name='Test application club';
begin perform public.finalize_representative_application(app,true,null);raise exception 'Owner finalized before teacher approval';exception when raise_exception then if sqlerrm='Owner finalized before teacher approval' then raise;end if;end;
end$$;
reset role;
insert into public.teacher_approval_tokens(application_id,token_hash,expires_at) select id,repeat('a',64),now()+interval '48 hours' from public.representative_applications where club_name='Test application club';
set local role service_role;
select public.review_teacher_application(repeat('a',64),true);
do $$begin
if not exists(select 1 from public.application_notification_outbox where sent_at is null) then raise exception 'Owner notification not queued';end if;
if (select role from public.user_roles where user_id='11000000-0000-4000-8000-000000000002')<>'Student' then raise exception 'Teacher approval promoted applicant';end if;
begin perform public.review_teacher_application(repeat('a',64),true);raise exception 'Approval token reusable';exception when raise_exception then if sqlerrm='Approval token reusable' then raise;end if;end;
end$$;
reset role;
set local role authenticated;
select public.finalize_representative_application(id,true,null) from public.representative_applications where club_name='Test application club';
reset role;
do $$begin
if (select role from public.user_roles where user_id='11000000-0000-4000-8000-000000000002')<>'Representative' then raise exception 'Final approval did not grant role';end if;
if not exists(select 1 from public.organization_representatives a join public.organizations o on o.id=a.organization_id where a.user_id='11000000-0000-4000-8000-000000000002' and o.name='Test application club') then raise exception 'Final approval did not assign correct club';end if;
end$$;
rollback;
select 'Application authorization checks passed' as result;

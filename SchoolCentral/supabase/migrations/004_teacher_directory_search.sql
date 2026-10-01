-- Only the authorized teacher name/email directory becomes readable.
-- Owner-only write policies and server-side application validation are unchanged.
create policy teachers_directory_read on public.approved_teachers
for select to authenticated using ((select public.is_active()));

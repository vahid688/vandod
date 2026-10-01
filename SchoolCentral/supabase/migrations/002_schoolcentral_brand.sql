-- Update existing installations while preserving custom platform names.
alter table public.settings alter column school_name set default 'SchoolCentral';
update public.settings set school_name='SchoolCentral' where school_name='SchoolHub';

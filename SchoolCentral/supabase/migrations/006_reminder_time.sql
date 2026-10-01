alter table public.notification_preferences
 add column reminder_minutes integer not null default 1440
 check (reminder_minutes in (5,10,15,30,60,120,360,720,1440));

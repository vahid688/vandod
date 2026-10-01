# Project brief

SchoolCentral is a private school events PWA built for students, teachers, coaches and club leaders. All calendar/event content requires login. Build web first; later Expo/React Native clients must share Supabase users and data. No native app exists yet.

Roles are exactly Student, Representative, Owner. Every signup starts as Student. The sole Owner is Vandod Namazi, intended email vnnamazi@gmail.com. No public Owner signup or self-promotion exists. Representatives manage events only for assigned organizations; Students browse and enrol. Owner manages events, organizations, categories, accounts, teacher authorization and representative applications.

Core workflows: signup/login → Home → browse → event detail → enrol/cancel; Owner creates organizations and assigns representatives; Representative creates/edits/deletes scoped events visible to students; Student application → authorized teacher email review → Owner final approval → scoped Representative role.

V1 excludes chat, attendance, capacity/registration booking, analytics, multi-school support and native clients. Email notifications were explicitly added later by the user: enrolled-event reminders and change/cancellation updates.

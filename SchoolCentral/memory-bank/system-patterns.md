# Architecture and source map

Next.js App Router, React/TypeScript, Tailwind, Lucide, Radix/CVA button. Supabase Auth/Postgres is shared source of truth. Server-only email uses Resend. Local demo explicitly enabled by NEXT_PUBLIC_DEMO_MODE=true, never a silent production fallback.

- src/components/schoolhub.tsx: main app, routing/state, auth UI, calendar, directories, CRUD, enrollment and notification prompt. Large compact component; refactor carefully rather than rewriting established behavior.
- src/components/account-settings.tsx: personal settings and notification email/timing controls.
- src/components/representative-applications.tsx: applicant/Owner application views, teacher administration.
- src/components/teacher-picker.tsx: searchable authorized teachers.
- src/domain: framework-light types, event validation and application validation.
- src/data: repository, Supabase client, seed data.
- src/server/application-service.ts: server authentication, service-role client, token hashes and Resend delivery.
- src/app/api: application submission/review/Owner delivery and scheduled event-notification endpoint.
- src/app/teacher-review: bearer-link review flow; viewing never approves.
- public/sw.js: public offline shell/assets only; do not cache private data.
- supabase/migrations: ordered schema/brand/application/teacher-directory/notification/reminder migrations.

Security: RLS is authoritative. Student cannot write events/roles; Representative event writes only assigned organizations; Owner sole role unique index and Owner-only assignment RPC. Notification preferences own-user RLS, service-only email queue. Keys with elevated privileges never public. Teacher token 256-bit random, hashed in DB, single-use, 48-hour expiry. Email endpoints validate authenticated requests or scheduled-job secret.

Notification job queues reminders within selected interval, and database trigger queues material changes/cancellations. Delivery rechecks preferences, active profiles, enrollments and current event timing; uses Resend idempotency keys. Pending batch limit 100. Queue processing is not yet live-tested. Review cancellation opt-out and concurrency/retry behavior before launch.

# SchoolCentral

## Start here: website source code

This folder contains the complete website source code. The app currently works as a local demo; real school use requires Supabase and email configuration described below.

| File or folder | Purpose |
| --- | --- |
| `src/app/page.tsx` | Website entry page |
| `src/components/schoolhub.tsx` | Main screens, navigation and application UI |
| `src/components/account-settings.tsx` | Profile settings and Representative application entry |
| `src/components/representative-applications.tsx` | Application forms, Owner reviews and teacher email list |
| `src/app/globals.css` | Responsive desktop/mobile styling |
| `src/app/layout.tsx` | Browser title and app metadata |
| `src/domain/` | Shared types, permissions and validation |
| `src/data/` | Supabase data access and local demo data |
| `src/server/application-service.ts` | Secure approval emails and token handling |
| `src/app/api/` | Server endpoints for applications and teacher reviews |
| `supabase/migrations/` | Database schema, RLS and approval permissions |
| `public/` | PWA icons, service worker and offline page |
| `.env.example` | Configuration template; no actual secrets |

To run the demo: install dependencies with `pnpm install`, copy `.env.example` to `.env.local`, set `NEXT_PUBLIC_DEMO_MODE=true`, and run `pnpm dev`. Open http://localhost:3000. To check the code, run `pnpm typecheck`, `pnpm lint`, `pnpm test`, and `pnpm build`.

The detailed setup, secure Owner bootstrap, deployment, email approval configuration and verification instructions follow.

A mobile-first Next.js PWA for one school, with Student, Representative, and a sole Owner. Supabase Auth and Postgres are the source of truth. The UI uses React, TypeScript, Tailwind 4, a shadcn-style Radix/CVA Button and Lucide. The month calendar is a small accessible CSS grid rather than another calendar dependency.

## Quick start

Requirements: Node 22.18+ and pnpm 11 (or npm). This checkout includes a pnpm lockfile.

```sh
pnpm install
cp .env.example .env.local
# Set NEXT_PUBLIC_DEMO_MODE=true for a local demo; leave Supabase keys empty.
pnpm dev
```

Open http://localhost:3000. In Windows PowerShell use `Copy-Item .env.example .env.local` instead of `cp`. This machine's bundled Node is at `C:\Users\Arsen\.cache\codex-runtimes\codex-primary-runtime\dependencies\node\bin\node.exe`; add its directory to PATH if Node is unavailable.

## Demo mode

Demo mode requires the explicit `NEXT_PUBLIC_DEMO_MODE=true` flag. Without Supabase configuration and without this flag, the app shows a setup message and never silently enables a backend bypass. When enabled it does not instantiate a Supabase client at all.

The login screen provides three local demo accounts: `student@demo.school`, `rep@demo.school`, and `vnnamazi@gmail.com`. Login accepts any password of at least eight characters; demo signup creates a local Student. Demo accounts are fictional and do **not** implement production identity security. Data lives in this browser's localStorage and the session identity in sessionStorage. Passwords are never stored. Use only fictional data. Clear the `schoolhub-demo-v1` storage key to reset data; sign out to reset identity. There is no role switcher inside the authenticated application.

Try these workflows:

1. Student: sign in, browse Home/Calendar/Events, search and filter, open an event, save it, then find it under Saved.
2. Owner: open the Owner dashboard from the sidebar (mobile: menu), add an organization, find a user, check their assigned organizations, and save assignments. Clear assignments to revoke Representative access. Accounts can be disabled; the Owner cannot be disabled.
3. Representative: open Representative Portal, choose an assigned organization, create a published event, edit it from event details, then delete with confirmation. Sign out and log in as Student to see the same persisted records.
4. Owner: create/edit/delete events, organizations and categories; manage users and assignments; edit school name and timezone. Referenced organizations/categories cannot be deleted until their events are moved or deleted.

## Supabase setup

Create a Supabase project. Copy its URL and publishable/anon client key into `.env.local`:

```env
NEXT_PUBLIC_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=YOUR_PUBLIC_KEY
NEXT_PUBLIC_DEMO_MODE=false
```

Never put a service-role key in the browser, a `NEXT_PUBLIC_` variable, source control, in client configuration. Calendar and directory data access uses the authenticated user's JWT and the public key; application email delivery uses a separate server-only service key as documented below. Public keys are safe only with the supplied RLS policies.

Configure Auth → URL Configuration with your local and production URLs and allowed redirects. Enable email/password authentication and email confirmation. Configure production SMTP before inviting real students. Users must confirm their address when confirmation is enabled. Refreshing after confirmation signs them in if Supabase has established the session. The app handles email confirmation via the Supabase browser client's URL session detection.

Use the Supabase SQL Editor to run `supabase/migrations/001_schoolhub.sql` **once on a fresh database**, then migrations 002 and 003 in order. Alternatively with the Supabase CLI:

```sh
supabase login
supabase link --project-ref YOUR_PROJECT_REF
supabase db push
```

For a local backend, install Docker and the Supabase CLI, run `supabase start`, then `supabase db reset`. Use the URL and anon key printed by `supabase status`. Resetting destroys local data; use only a disposable development database.

### Securely bootstrap the sole Owner

Sign up normally in the app and confirm your email first. Every new auth account gets a Student role from a database trigger regardless of client-supplied metadata. Then, as a trusted database administrator in SQL Editor, use the actual UUID of your own verified account:

```sql
begin;
update public.user_roles
set role = 'Owner'
where user_id = 'YOUR_VERIFIED_AUTH_USER_UUID'::uuid;
commit;
```

Verify exactly one row changed. A partial unique index forbids a second Owner. No app UI, RPC, or authenticated table privilege can create an Owner. The only role-changing RPC is `assign_representative`, which requires the existing active Owner, rejects the Owner target, and atomically replaces assignments. A trusted SQL administrator could replace the Owner in a transaction for recovery; that is deliberately outside the application. Log out and back in after bootstrapping. Keep MFA enabled for your Supabase dashboard account.

### Seed data

`supabase/seed.sql` adds removable categories and organizations only; it does not create identities. After bootstrapping the Owner, run `supabase/demo-events.sql` in SQL Editor to add six realistic, removable sample events with the Owner audit identity. That script refuses to run without an Owner. It tags descriptions with `[DEMO]` and avoids inserting the same samples twice. To remove them:

```sql
delete from public.events where description like '[DEMO]%';
```

Remove sample organizations/categories individually through the Owner UI after deleting their sample events. Review names before deleting in a database containing real records.

## Authorization and integrity

- All eight domain tables have RLS enabled. Anonymous users have no domain table privileges; public pages render only an authentication shell.
- Students can read published events and school directories and manage only their own favorites. Drafts are visible only to eligible event managers.
- Representatives need both the Representative role and a matching organization assignment. Event updates check **both** the existing organization and new organization, preventing moves into unauthorized organizations.
- Only an active Owner can mutate organizations, categories, settings and user account status. Direct role and assignment writes are revoked even for the Owner; the authorized RPC handles assignments.
- Disabled profiles lose domain access through RLS. The Owner cannot be disabled. Audit triggers always derive authors from `auth.uid()`, preserving original creation identity/time on edits.
- UUID primary keys, foreign keys, unique names, status/time/URL/color constraints and lookup indexes enforce data integrity. Referenced event parents use `ON DELETE RESTRICT`; favorites are removed when an event is deleted.
- Permissions come from database rows, not user-editable auth metadata or stale JWT role claims. A copied or modified client does not gain privileges.

The frontend guards controls as a usability aid; **RLS is the security boundary**. Keep Supabase RLS enabled and avoid adding broad table grants or service-role calls to this client. Security follows the official [Supabase RLS guidance](https://supabase.com/docs/guides/database/postgres/row-level-security).

## Architecture

`src/domain/types.ts` holds browser-independent domain types, permission helpers, and validation. `src/data/repository.ts` maps the Supabase schema into domain state and writes via the authenticated client. `src/data/supabase.ts` selects the explicit runtime backend. `src/data/seed.ts` creates relative-date fictional data for the local demo. `src/components/schoolhub.tsx` owns the responsive UI, auth flow and local view state. Screen transitions currently use client state on the root route; independent deep-linked screen URLs can be added later without changing the database.

Fresh data is loaded after every mutation and whenever the tab regains focus, with a 15-second refresh fallback. Supabase Realtime also refreshes the shared state when events change. A Representative's own save appears immediately; other connected clients update when their subscription receives the change. No optimistic updates hide database failures. Errors and successful writes show status toasts.

For future Expo/React Native clients, reuse the domain types and the same Supabase schema, Auth users, RLS, and assignment RPC. Inject a React Native-compatible Supabase client and secure session storage into a mobile repository adapter. Do not copy the browser component or demo localStorage layer. Use shared UTC timestamps and school timezone display; native UI and navigation remain separate. No browser-only APIs exist in the domain model.

## Verification

```sh
pnpm typecheck
pnpm lint
pnpm test
pnpm build
```

Domain tests cover assignment scope, disabled accounts and event validation. `supabase/tests/authorization.sql` exercises real database access for anonymous, Student, Representative and Owner sessions inside a rolled-back transaction. Run it **against a freshly migrated disposable local database** with `psql -v ON_ERROR_STOP=1 -f supabase/tests/authorization.sql YOUR_LOCAL_DATABASE_URL`. Do not run fixtures on a production database. This requires a local Supabase instance; frontend tests do not substitute for running SQL authorization tests.

Manual production-backend acceptance: create two confirmed Students, bootstrap one Owner, assign the other to one organization, sign in as each role in separate browser profiles, and run the four workflows above. Also attempt requests directly with each session JWT: Student event inserts/role updates must fail; Representative event writes in an unassigned organization must fail; anonymous domain reads must fail. A published event must appear for the Student; a draft must remain invisible. Test login errors, signup confirmation, empty lists, deletion constraints, and timezone rendering.

## PWA installation and offline behavior

Production builds register `public/sw.js`. The manifest has standalone display and real 192/512 PNG icons. The worker caches only public icons and a small offline page, using network-first navigations. It never caches Supabase API responses, authenticated HTML, private events, or user data. Offline navigation explains that a connection is required. An already-open session may retain rendered in-memory data until reloading; writes require connectivity and errors are shown. Follow the [Next.js PWA guide](https://nextjs.org/docs/app/guides/progressive-web-apps) for browser-specific installation behavior.

```sh
pnpm build
pnpm start
```

Test on localhost or HTTPS. In Chrome/Edge use the address bar installation button; on iOS Safari choose Share → Add to Home Screen. Check DevTools Application → Manifest and Service Workers. Simulate offline and reload: the private calendar should be replaced by the offline explanation. If changing the shell cache, increment its version; activate removes older SchoolCentral caches. Development intentionally does not register the worker. Clear a previous production worker when returning to development.

## Deployment

Deploy as a standard Next.js application on Vercel or another Node-compatible host. Use the project directory as the root. Set the Supabase public variables, set demo mode to false, and configure the deployed URL in Supabase Auth. Environment variables with `NEXT_PUBLIC_` are embedded at build time; rebuild after changing them. Keep HTTPS enabled for installability. Run migrations before exposing the application, bootstrap the Owner, and run the authorization checks before inviting students. No hosted Supabase project or production deployment is provisioned by this checkout.

## Representative applications and teacher approval

Students open account settings using their sidebar name or top-right avatar, then select **Apply for Representative** at the bottom. The sign-up checkbox has been removed. Creating an account always creates a Student. Applications include club name, a brief description and the approving teacher's email. The flow is:

1. The Owner authorizes teacher email addresses under **Owner dashboard → Teachers**. This is an email allowlist, not a fourth platform role. Independently verify each teacher's identity before adding their address.
2. A confirmed, active user submits an application. The teacher address must already be on the allowlist. The applicant keeps their current role and event permissions.
3. The teacher receives a single-use, 48-hour approval link. Visiting the link displays the application; it does **not** approve it. The teacher explicitly approves or declines on the review page. Mailbox access to an Owner-authorized address is the verification mechanism; teachers must not forward these bearer links.
4. Teacher approval puts the application in the Owner review queue, adds a pending badge to the dashboard, and queues an email to the sole Owner's current Auth email address.
5. The Owner chooses an existing organization or creates one from the application, then approves. A database transaction adds the Representative role and assignment for that organization, preserving existing assignments. Declines grant no access. Removing a teacher's authorization invalidates outstanding teacher links and prevents final approval of that teacher's endorsements.

### Required configuration

Apply **all three** migrations to a fresh database. For an existing installation with migration 001 already applied, run migrations 002 and 003 in order; do not rerun 001. The client now loads application tables, so apply migration 003 before using the updated production frontend. Supabase CLI `supabase db push` handles pending migrations for a correctly linked migration history.

Add these **server-only** environment variables to the Node host's environment (not `NEXT_PUBLIC_` variables):

```env
SUPABASE_SERVICE_ROLE_KEY=YOUR_SERVER_ONLY_SERVICE_ROLE_KEY
RESEND_API_KEY=YOUR_RESEND_API_KEY
EMAIL_FROM=SchoolCentral <approvals@YOUR_VERIFIED_DOMAIN>
SITE_URL=https://YOUR_CANONICAL_APP_DOMAIN
```

Create a Resend account and verify the sender domain. For local development, `SITE_URL=http://localhost:3000` is supported; teachers outside your computer need a publicly reachable HTTPS deployment. The school-approved recipient emails are managed in SchoolCentral; Supabase Auth SMTP settings alone do not send these application emails. Email uses the [Resend send-email API](https://resend.com/docs/api-reference/emails/send-email). The server-only Supabase client follows [Supabase's secret-key guidance](https://supabase.com/docs/guides/database/secure-data); never expose the service key to a browser/native client.

`POST /api/representative-applications` verifies the user's JWT, then invokes the restricted submission RPC. The server prepares a random 256-bit token and stores only its SHA-256 hash. The raw token is included in the email URL fragment and removed from browser history when the review page loads. Review requests use POST; token endpoints never return tokens to applicants. RLS denies all client access to approval tokens, delivery attempts and the email notification outbox. Teacher review RPC execution is reserved for the server service role. Only the active Owner can invoke final approval or manage the teacher allowlist.

Duplicate open applications for the same user/club are blocked. Resending a teacher email is limited to once per five minutes; regenerating a link invalidates the previous one. Delivery failures leave the application pending, with a **Resend teacher email** action. Owner notifications use a durable outbox and provider idempotency keys: delivery is attempted immediately after teacher approval and retried when the Owner opens Applications. If a continuous background email retry is required, add a scheduled server worker for the outbox; the current version retries on those two triggers. The Owner's in-app queue remains available even if email fails.

The explicitly isolated **local demo sends no email**. It provides a fictional `teacher@demo.school` allowlist entry; Owners can add others. Owners can simulate teacher approval/decline from the Applications tab, then perform their own separate final decision. These simulation controls exist only when demo mode is enabled. Existing demo storage is migrated in place without deleting accounts/events.

### Application verification

`pnpm test` now includes two application validation tests (six total tests). `supabase/tests/applications.sql` adds database checks for unauthorized teacher addresses, direct status/teacher-list writes, application privacy, teacher-token replay, the Owner email outbox, and no role grant until both stages complete. Run it with `psql -v ON_ERROR_STOP=1 -f supabase/tests/applications.sql YOUR_DISPOSABLE_DATABASE_URL`, after all migrations, against a disposable database without an existing Owner. It rolls back fixtures.

Live acceptance: authorize a real teacher, submit as a confirmed Student, verify that the teacher email arrives, approve via its link, verify the Owner email and queue badge, confirm the Student still cannot write events, then approve as Owner and verify access only to the selected organization. Test teacher decline, Owner decline, expired/replayed links, removed teacher authorization and email failure/resend. These live email/database checks still require your configured Supabase and Resend accounts.

## V1 limits

This is a focused, functional V1. It has no general notifications, chat, attendance, event registration, analytics, multi-school support or native apps. Account management supports viewing users, organization assignments and disabling access; deletion of Auth identities remains a trusted Supabase administrative operation. User search currently loads the Owner-visible directory and filters client-side; add paginated server-side queries if the school grows large. Event dates are stored in UTC and displayed in the school timezone; the editor explicitly labels inputs as device-local time. All-day dates are inclusive of the stored end date. The compact month grid has a selected-day event list for phones. Forms and dialogs use native controls; notification styling is custom.



Approved Representatives see Representative Portal and no application section in account settings. Students access applications through account settings and cannot open the Portal. If status changes while the application screen is open, the interface switches to the Portal after approval; revoked Representatives are returned to Home.



## Searchable teacher directory
Applicants now search authorized teachers by name or school email and select a result. Arbitrary email input is removed. Apply migration 004_teacher_directory_search.sql after migration 003 on an existing Supabase installation. Active authenticated users can read teacher names and emails; only the Owner can modify the list. Application submission still rechecks that the selected teacher is authorized. The local demo uses the Owner-maintained list already stored on this device.




### Event enrollment and notification emails

Saved events are now called enrolled events; existing favorites are retained as enrollments. Enrollment is not attendance tracking or a capacity booking. After enrolling, users may enable both reminders and change emails. Settings → Notifications lets each user change only their notification email and toggle the two email types independently. Login email is unaffected.

Apply migration `005_event_notifications.sql` for existing databases (the fresh installer includes it). Preferences use per-user RLS; the delivery queue is server-only. Configure Supabase service credentials, Resend and a verified EMAIL_FROM as described above. Set a long random `NOTIFICATION_JOB_SECRET`. Configure your hosting scheduler to POST `/api/event-notifications` every 5 minutes with `Authorization: Bearer <NOTIFICATION_JOB_SECRET>` over HTTPS. No browser secret is needed. Reminders are delivered in the 24-hour window before the event, or soon after enrolling within that window. Updates and cancellations are queued by database triggers. Delivery uses idempotency keys and checks active accounts and preferences before sending; cancelled enrollments receive no future reminders. Run the job regularly until the pending queue is drained.

Local demo saves preferences on this device and never sends email. Actual migration execution and email delivery remain unverified until a Supabase project and email provider are connected.

Reminder timing: apply migration `006_reminder_time.sql` on existing databases. Users choose 5, 10, 15, 30 minutes or 1, 2, 6, 12, 24 hours before events. Existing preferences default to 24 hours. The delivery worker respects this choice; schedule it every minute for the best timing of short reminders. Email arrival can vary with scheduler and provider delays.

# Verification record

Verified in this workspace on September 29, 2026 (America/Toronto).

- Next.js production build: passed, including compilation and type validation.
- TypeScript `tsc --noEmit`: passed.
- ESLint: passed with no errors or warnings after the configuration fixes.
- Node domain tests: four passed (Student write denial, Representative organization scope, disabled Owner denial, invalid event validation).
- Browser local demo: Student event details, save, Saved directory, and unsave passed.
- Browser local demo: Representative Portal offered only assigned organizations in the event creation form; published a new event and verified it from the Student Events directory.
- Browser local demo: Owner created Debate Society, found a registered Student, assigned them to that organization, verified Representative status, then revoked the assignment and verified Student status.
- Browser phone layout: Home and Calendar rendered with bottom navigation; measured viewport and document widths matched at 375 pixels, with no horizontal overflow.
- Browser desktop layout: visually inspected; preview saved alongside the project.
- PWA PNG icons generated, manifest route compiled, service worker excludes private data caches.

## Not verified here

Supabase credentials, a Postgres executable, Docker, and the Supabase CLI were unavailable. The migration, SQL seed scripts, live Auth flow, Realtime delivery across clients, and SQL authorization tests have **not** been executed against a real backend. Run the supplied SQL authorization test and real-backend acceptance workflow in README.md before deployment. Browser tests used the explicitly isolated local demo, not production RLS. Installation on a physical phone and offline service-worker behavior require production-mode testing over localhost/HTTPS.

No production host, project, or Owner identity was created. The local preview runs with a process-level demo flag; no credentials or `.env.local` are saved in the project.

## Representative application update

Production build, TypeScript, ESLint and six domain tests passed after adding the Student application form, Owner teacher allowlist, two-stage application review, email API endpoints and secure teacher review page. Database fixtures now include `supabase/tests/applications.sql`. Supabase/Resend credentials remain unavailable: real email delivery, migration execution and SQL authorization tests are unverified. Browser automation recovered in a fresh tab and verified Student submission, teacher-approval simulation, continued Student status before Owner approval, Owner final approval, and Representative Portal access limited to the approved Coding Society organization. The default demo Student account was restored afterward; the approved sample application remains as review history.


## Portal visibility demo
Typecheck and lint passed. A new fictional Taylor Demo account applied for Photography Club. Browser checks found zero Representative Portal controls after submission and after teacher approval. Following Owner final approval, the Portal appeared, Apply to represent disappeared, and the Portal showed only Photography Club. Screenshots of all three stages are saved alongside the project. Teacher approval was simulated in local demo mode; no real email was sent.


## Account settings update
Typecheck, lint and production build passed. Browser checks verified both profile buttons open settings, signup has no Representative checkbox, 24-hour times and Monday-first calendar render after saving, and the settings application button opens the application flow. Preferences are stored per user on this device; they are not backend account changes.


## Teacher picker update
Typecheck and lint passed. Browser checks verified case-insensitive name filtering, required teacher selection, and a no-match message using the configured local authorized teacher list. Supabase migration 004 is supplied but was not executed because database access is not configured.


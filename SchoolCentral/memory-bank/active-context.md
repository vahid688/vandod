# Active context — September 30, 2026

User requested source code plus structured memory bank for GitHub migration and continued GitHub Copilot development. This folder is the source export. No GitHub repo was created, no push performed, no production deployment exists.

Latest completed UX: enrol instead of save, enrolled section merged into Home, Enrolled tag only there, notification settings with separate email and reminder timing 5 minutes through 24 hours. Settings notification email never modifies Auth email. Local preview was running in demo mode before export; restart with pnpm dev after setting demo env.

User chose real accounts before publication but needs to create a Supabase project. Credentials unavailable. Database, email delivery and live Auth have not been verified. Do not claim production readiness.

During packaging a serious BEFORE-trigger return bug in migration 005 was discovered and corrected: queue_event_changes must return OLD on DELETE and NEW on UPDATE, including early exits. Source migration and fresh installer now agree. This SQL fix is reviewed statically only; validate against disposable Postgres before using real data. If older migration 005 has already been applied elsewhere, replace the function with corrected body via a new migration; do not assume editing a file updates a database.

Next priorities:
1. Install dependencies and run current checks on new machine.
2. Verify UI enrollment, timing persistence and cancellation flows in browser; latest UI changes were typechecked, not fully browser-regression-tested.
3. Connect real Supabase; run migrations and RLS/application fixtures in disposable project first.
4. Verify sole Owner bootstrap, signup confirmation and two-stage email application review.
5. Live-test event update/delete with notification trigger and queue; scheduler retries and opt-outs.
6. Review email-address verification for separate notification address before broad deployment (current settings accept syntactically valid address without proof of ownership).
7. Choose host, configure scheduler/provider and production URL, run mobile PWA checks.

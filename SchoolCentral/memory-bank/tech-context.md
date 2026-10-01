# Technical context

Use Node 22+ (tests use experimental-strip-types) and pnpm. pnpm-lock.yaml is included. No machine-specific runtime path is required.

```sh
pnpm install --frozen-lockfile
# Copy .env.example to .env.local; set NEXT_PUBLIC_DEMO_MODE=true for local demo
pnpm dev
pnpm typecheck
pnpm lint
pnpm test
pnpm build
```

Preview defaults to http://127.0.0.1:3000. Development output .next-dev, production .next. Demo browser data is localStorage schoolhub-demo-v1; signed-in demo identity sessionStorage schoolhub-demo-user. Notification/display preferences have per-user schoolcentral keys. Browser-local user edits are not part of this source export.

For real accounts: create Supabase project, apply supabase/install-fresh.sql ONCE to a fresh DB (includes migrations 001–006). For existing DB, apply only missing numbered migrations. Read REAL-ACCOUNTS-SETUP.md and README.md. Register/confirm intended Owner identity then run bootstrap-owner.sql in trusted SQL Editor; never expose service credentials. seed.sql and demo-events.sql are optional removable demo fixtures. SQL tests require disposable database.

Environment: NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY, NEXT_PUBLIC_DEMO_MODE=false; server-only SUPABASE_SERVICE_ROLE_KEY, RESEND_API_KEY, EMAIL_FROM on verified domain, SITE_URL, NOTIFICATION_JOB_SECRET. No populated credentials are included. Configure Auth site/redirect URLs and production HTTPS.

Schedule server-side POST /api/event-notifications every minute using Authorization: Bearer <NOTIFICATION_JOB_SECRET>. Do not expose the secret to browser code. Actual timing depends on scheduler/provider. Supply Resend configuration for teacher and Owner approval emails too.

Deploy to a Next.js-capable host chosen by user (none configured). Do not publish production in demo mode. Verify PWA in production on localhost/HTTPS and physical phone. Future native clients reuse Supabase/RLS and domain/data contracts.

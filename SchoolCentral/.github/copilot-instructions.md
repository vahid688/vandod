# SchoolCentral instructions

Read memory-bank/README.md, active-context.md and progress.md first. Preserve product decisions in product-context.md. Enforce permissions in Supabase RLS/server authorization, not just buttons. Never include secrets or silently enable demo in production. Exactly Student, Representative, Owner; sole Owner; all signup Student; teacher then Owner approval. Notification email is separate from login email. Avoid private PWA caches. Keep shared domain/backend suitable for future native clients.

Run pnpm typecheck, pnpm lint, pnpm test and pnpm build as appropriate. Use a disposable Supabase database for SQL policy/trigger tests. Report unverified backend/email behavior honestly. Update memory-bank after meaningful changes. No production hosting is configured; ask for actual project configuration when needed and continue local work.

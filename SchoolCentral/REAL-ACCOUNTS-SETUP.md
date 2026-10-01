# SchoolCentral: first live-account draft

This checklist connects the existing Next.js website to a fresh Supabase project. Demo data stays separate; it is not imported into real accounts.

1. In Supabase Dashboard, create a project called **SchoolCentral** in your organization. Choose a region near your school and create a strong database password. Keep that password in your password manager, not in chat or source control.
2. Once provisioning completes, open SQL Editor and run `supabase/install-fresh.sql`. This combines all four current migrations in one transaction and refuses to overwrite an existing SchoolCentral schema. Run it only on a fresh project. Use the individual migrations for an existing installation instead.
3. Copy `.env.example` to `.env.local`. Set `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` from the project's Connect/API Keys page. A publishable client key also works in the existing key variable. Keep `NEXT_PUBLIC_DEMO_MODE=false`. Never put a service-role key in that public variable.
4. Configure Auth → URL Configuration: Site URL `http://127.0.0.1:3000`; allow `http://localhost:3000` as an additional redirect. Set your final HTTPS website URL before deployment. Keep email confirmation enabled. Configure custom SMTP for reliable real-user confirmations; Supabase's default sender has limits and may restrict recipients.
5. Restart the local server with demo mode disabled. Sign up as **Vandod Namazi**, using **vnnamazi@gmail.com**, and confirm the email. Set your account password directly in the website.
6. Run `supabase/bootstrap-owner.sql` as a trusted SQL administrator. It checks your exact confirmed email and refuses to create a second Owner. Sign out and sign in again to load Owner access.
7. Add real categories/organizations and authorize teachers under Owner dashboard → Teachers. Do not run optional demo seed scripts unless you want fictional fixtures in the new project.
8. For teacher approvals, configure server-only `SUPABASE_SERVICE_ROLE_KEY`, `RESEND_API_KEY`, `EMAIL_FROM` from a verified sender domain, and `SITE_URL`. These are separate from Supabase Auth's confirmation SMTP. Restart after configuration.
9. Run the disposable database authorization tests and the acceptance workflow in README.md. Verify Student event-write denial, assigned-club-only Representative writes, teacher approval leaving the role as Student, and final Owner approval granting only the selected club.
10. Deploy the full Next.js app to a Node-compatible host with these environment variables. Static export is not sufficient for the server-side approval email endpoints. Then verify HTTPS, phone installation, offline behavior, and real email delivery before school-wide launch.

## Current status

The source code and schema are prepared. This document is not proof of a live backend, completed Owner signup, email delivery or a production deployment. Those steps require the newly created project and successful verification.

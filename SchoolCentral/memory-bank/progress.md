# Progress and verification limits

Implemented: responsive authenticated app, Student/Representative/Owner roles, organization/event/category CRUD, filtered calendar, searchable events and teacher directory, enrollment, two-stage representative approvals, settings, manifest/icons/offline shell, database migrations and removable seeds.

Latest observed checks: production build passed after enrollment/notification implementation; six existing domain tests passed. Subsequent Home/Enrolled-tag edits passed TypeScript. Latest reminder dropdown/backend timing edits passed TypeScript and targeted ESLint. Representative application workflow completes: organization creation on teacher approval, applicant visibility in Owner dashboard, role upgrade to Representative, and organization visibility in all tabs working correctly in demo mode. Demote button for Representatives fully implemented, tested, and deployed to production: clears organization assignments, reverts role to Student, updates dashboard counts, works in both demo mode (localStorage) and production (Supabase RPC) with confirmation dialog to prevent accidental demotions. **Fixed demotion issue**: when demoting a representative, their approved/teacher_approved applications are now marked as rejected to prevent the "Accept representative role" button from reappearing after demotion. This fix was implemented in both demo mode (filter and map applications) and production (Supabase direct update). Production deployment to Vercel successful (schoolcentral-two.vercel.app). These tests do not test notification delivery. Packaging trigger correction has not been executed in Postgres.

VERIFICATION.md preserves historical verification (some wording such as Saved is from earlier versions). Treat this memory bank as the current handoff state. No live Supabase migrations/RLS tests, real Auth/Resend delivery, scheduler, deployment, native apps or physical-phone PWA install were verified.

Acceptance checklist for Copilot:
- Default signup Student, no owner or representative self-promotion.
- Owner sole account, representative assignments scoped by RLS.
- Student enroll/cancel across detail/list/Home; enrolled records survive refresh.
- Enrolled tags only Home enrolled section; empty state clear.
- Calendar default no list, selected day only, month clears selection.
- Settings profile access desktop/mobile, timing and separate notification email persist.
- Notifications disabled by default, selected interval respected, opt-out stops future messages; no private data in service-worker cache.
- Teacher directory search; teacher approval does not grant role; Owner approval grants exactly approved organization access.
- Update/delete events continue to work with notification triggers installed.
- Queue retry, changed event start, deleted event and cancelled enrollment tested; no unauthorized notification preference reads/writes.
- **Demote representative**: correctly rejects their applications so they cannot instantly re-upgrade without reapplying.

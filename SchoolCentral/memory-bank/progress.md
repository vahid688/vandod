# Progress and verification limits

Implemented: responsive authenticated app, Student/Representative/Owner roles, organization/event/category CRUD, filtered calendar, searchable events and teacher directory, enrollment, two-stage representative approvals, settings, manifest/icons/offline shell, database migrations and removable seeds.

Latest observed checks: production build passed after enrollment/notification implementation; six existing domain tests passed. Subsequent Home/Enrolled-tag edits passed TypeScript. Latest reminder dropdown/backend timing edits passed TypeScript and targeted ESLint. These tests do not test notification delivery. Packaging trigger correction has not been executed in Postgres.

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

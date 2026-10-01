# Product context and accepted decisions

- Brand all visible product names SchoolCentral. Some internal filenames/package names remain schoolhub.
- Mobile bottom navigation, desktop sidebar, serious simple styling, accessible forms and dialogs.
- Home shows Your enrolled events above Today and Coming up. Separate Enrolled navigation removed.
- Enrolled tags appear only in Home's Your enrolled events section; other lists retain accessible enrollment controls without that text. Enrol replaces the former save/favorite concept; favorites remains the database relation. Existing records are preserved.
- Calendar is month-first with organization/category filters. No list below until a date is clicked; show selected-day events. Changing month clears selection.
- Profile controls open personal Settings. Display settings include clock format, first weekday, density; stored per account on this device.
- Settings has Notifications: separate notification email, Email reminders checkbox and timing dropdown (5,10,15,30 minutes; 1,2,6,12,24 hours), event change/cancellation checkbox. Login email stays unchanged. Enrollment offers notification activation popup. Defaults: disabled notifications, 24-hour reminder timing.
- Students apply for Representative from bottom of personal Settings, with brief explanation. No signup application checkbox and no portal before final approval. Remove application section once Representative approved.
- Applicant supplies club, description and teacher selected through searchable Owner-authorized teacher directory. Teacher approval first, then notify Owner for final approval. Teacher approval alone never grants role/access.
- Owner Admin Users includes all users; Representatives filters only Representative accounts. Owner platform-name/timezone Settings tab removed; personal Settings remains.
- Demo login shortcuts select one active account of each role, not first three profiles, so promotions do not duplicate labels. If no Student exists, demo creates a separate demo Student.

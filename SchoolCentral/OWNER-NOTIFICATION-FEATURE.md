# Owner Email Notification on Teacher Approval

## Summary
When a teacher approves a club application, the Owner now receives an email notification with the club details, representative name, and which teacher approved it.

## Changes Made

### 1. Updated Teacher Review Endpoint
**File**: `src/app/api/teacher-review/route.ts`
- Added import: `sendOwnerApprovalNotification`
- When teacher approves an application (`input.action==='approve'`):
  - Executes the teacher review in the database
  - Calls `sendOwnerApprovalNotification()` to send Owner notification
  - Error handling: silently continues if email fails (durable outbox ensures it's retried)

### 2. Added Owner Notification Function
**File**: `src/server/application-service.ts`
- New function: `sendOwnerApprovalNotification()`
- Fetches the Owner's email from user_roles table
- Retrieves the most recently approved application
- Sends email with:
  - Subject: "SchoolCentral: New club approved"
  - Club name
  - Representative name
  - Teacher email who approved it
  - Club description
  - Link to SchoolCentral

### 3. Restored TeacherDirectory Component
**File**: `src/components/representative-applications.tsx`
- Added `TeacherDirectory` export that was missing
- Allows Owner to manage authorized teachers in admin panel
- Features:
  - Add teacher emails
  - Remove teacher emails
  - Shows list of authorized teachers with dates added
  - Includes demo mode support

### 4. Created Teacher Management API
**File**: `src/app/api/teacher-management/route.ts` (new)
- POST endpoint for adding/removing authorized teachers
- Validates Owner role
- Handles:
  - `action: 'add'` - adds teacher email to approved_teachers table
  - `action: 'remove'` - removes teacher email
  - Duplicate email handling (returns clear error)

## Email Example

```
Subject: SchoolCentral: New club approved

A new club has been approved and added to SchoolCentral.

Club: Robotics Club
Representative: John Smith
Approved by teacher: mrs.johnson@school.edu

Description:
We build and compete with robots. Open to all skill levels.

Visit SchoolCentral to manage this club.
https://schoolcentral-two.vercel.app
```

## Workflow

1. Student submits club application with teacher email
2. Teacher receives approval email with secure link
3. Teacher clicks link and approves application
4. Database creates organization and grants Representative access to student
5. **Owner receives email notification about new approved club** ← NEW
6. Student sees "approved" status in their applications
7. Owner can view approved clubs in Applications dashboard (read-only audit view)

## Database Details

- Query uses `status='approved'` to find most recently approved club
- Email includes all fields from representative_applications table
- Idempotency key: `owner-approval:{application_id}` prevents duplicate sends
- Resend API handles delivery; failures logged but don't block workflow

## Testing Checklist

- [ ] Deploy Supabase migration to production database
- [ ] Submit test application in production
- [ ] Verify teacher receives approval email
- [ ] Teacher clicks link and approves
- [ ] Verify Owner receives notification email with club details
- [ ] Test multiple approvals to ensure notifications work
- [ ] Test demo mode: verify demo-only notifications work

# Complete Backend Setup Guide

## Quick Answer: Why Supabase?

### The Simple Explanation
Your app has two parts:
1. **Frontend** (UI users see) ✅ Already working
2. **Backend** (where data lives) ❌ Currently demo only

**Demo mode** = data in browser only
**Supabase** = real database that persists

### What Supabase Provides
```
┌─ Your App ─┐
│            │
└─────┬──────┘
      │ (API calls)
      ↓
┌─────────────────────┐
│  Supabase           │
├─────────────────────┤
│ • PostgreSQL DB     │
│ • Authentication    │
│ • RLS Policies      │
│ • Real Users        │
│ • Permanent Storage │
└─────────────────────┘
```

Without it: data disappears when browser closes
With it: data persists forever on their secure servers

## Complete Resend Setup (Copy & Paste)

### 1. Resend Account Creation
```
URL: https://resend.com
1. Click "Sign Up"
2. Enter email
3. Verify email
4. Create password
5. Login
```

### 2. Get API Key
```
Dashboard → Settings → API Keys
Click "Create API Key"
Name: SchoolCentral
Copy: re_abc123...
```

### 3. Update .env.local
File: `c:\git\vandod\SchoolCentral\.env.local`

```bash
NEXT_PUBLIC_DEMO_MODE=true

# Email Service
RESEND_API_KEY=re_abc123...
EMAIL_FROM=SchoolCentral <onboarding@resend.dev>

# App Configuration
SITE_URL=http://localhost:3000
NOTIFICATION_JOB_SECRET=

# Database (fill later)
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
```

### 4. Which EMAIL_FROM Should You Use?

#### Option A: Resend Test Domain (Recommended for now)
```
EMAIL_FROM=SchoolCentral <onboarding@resend.dev>
```
- ✅ No setup
- ✅ Works immediately
- ❌ Limit: 50 emails/day
- ✅ Perfect for testing

#### Option B: Your School Domain
```
EMAIL_FROM=SchoolCentral <approvals@yourschool.edu>
```
- ✅ Professional
- ❌ Need to verify domain (add DNS records)
- ✅ Unlimited emails
- ✅ For production

**I recommend starting with Option A, upgrade to B later**

### 5. Restart & Test
```bash
# Ctrl+C to stop server
# Then run:
pnpm dev

# In browser, go to http://127.0.0.1:3000
# Sign in as Student demo
# Submit representative application
# Check your email for approval link!
```

## Why These Environment Variables?

```bash
RESEND_API_KEY
├─ Your secret key to send emails
├─ Format: re_abc123...
└─ Like a password - keep it safe!

EMAIL_FROM
├─ Where emails appear to come from
├─ "SchoolCentral <approvals@domain>"
└─ Must match verified domain in Resend

SITE_URL
├─ Where your app lives
├─ Used in email links
├─ Local: http://localhost:3000
└─ Production: https://yourschool.edu

NOTIFICATION_JOB_SECRET
├─ Secret token for background jobs
├─ Prevents unauthorized email triggers
└─ Generate: openssl rand -hex 32
```

## What Gets Emailed?

### 1. Teacher Approval Email
**When:** Student applies for Representative role
**To:** Selected teacher
**Content:** Application details + secure approval link (48hr expiry)
**Example:**
```
From: SchoolCentral <onboarding@resend.dev>
To: teacher@school.edu
Subject: SchoolCentral: representative application for your review

John Doe has applied to represent Science Club.

Description: Our club focuses on physics and chemistry experiments.

Review and approve or decline this application:
[LINK]

This link expires in 48 hours and can be used once.
```

### 2. Owner Notification Email
**When:** Teacher approves the application
**To:** School Owner
**Content:** Summary of approved application + link to Owner dashboard
**Example:**
```
From: SchoolCentral <onboarding@resend.dev>
To: owner@school.edu
Subject: SchoolCentral: teacher-approved application awaits you

John Doe's application for Science Club has been approved by their teacher.

Sign in to SchoolCentral and open Owner dashboard → Applications to 
approve or decline it.
```

### 3. Event Reminder Email
**When:** Before enrolled event (timing set by user: 5min-24hrs)
**To:** Student who enrolled
**Content:** Event details + time until event
**Example:**
```
From: SchoolCentral <onboarding@resend.dev>
To: student@school.edu
Subject: Science Club Meeting starts in 24 hours

Science Club Meeting
Friday, October 4 at 3:00 PM
Location: Lab Room 204

You enrolled in this event. See you there!
```

## Testing Checklist

```
☐ Resend account created
☐ API key copied
☐ .env.local updated with API key
☐ Dev server restarted
☐ Signed in as Student demo
☐ Submitted representative application
☐ Email received in inbox
☐ Clicked approval link in email
☐ Application marked as "teacher_approved"
☐ Owner notification email received
```

## Resend Pricing & Limits

| Plan | Cost | Emails/Day | Features |
|------|------|-----------|----------|
| Free | $0 | 100 | Basic transactional |
| Pay-as-you-go | $0.20/email | Unlimited | Delivery tracking |
| Enterprise | Custom | Custom | Advanced features |

**For a school:**
- Free tier (100/day) = ~3,000 emails/month
- Perfect for notifications + approvals
- Pay-as-you-go if you grow larger

## Troubleshooting

### Email not sending: "Email delivery failed"
1. Check API key is correct (no spaces, full key)
2. Verify EMAIL_FROM domain is allowed
3. Restart dev server after env changes
4. Check browser console for errors

### Domain verification timeout
1. DNS changes take 5-30 minutes
2. Check propagation: https://dnschecker.org
3. Verify all records added correctly in DNS admin

### 50 email/day limit reached (Resend dev domain)
1. Upgrade EMAIL_FROM to verified domain
2. Or wait until next day (resets at UTC)
3. For production, always use verified domain

## Next Steps

After Resend is working:
1. Test full application workflow
2. Set up Supabase database (adds persistence)
3. Configure background scheduler
4. Deploy to production host
5. Set up real domain

See SUPABASE-SETUP.md for database configuration when ready!

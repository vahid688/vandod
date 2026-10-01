# Resend Setup Guide for SchoolCentral

## What is Resend?
Resend is a transactional email API that handles:
- Teacher approval emails (when reps apply)
- Owner notification emails (when teachers approve)
- Event reminder emails (24hrs before events)
- Email delivery tracking & retries

## Quick Start Checklist

### 1. Get Resend API Key
- [ ] Go to https://resend.com
- [ ] Sign up (free tier: 100 emails/day)
- [ ] Navigate to Settings → API Keys
- [ ] Create new API key
- [ ] Copy it (looks like: `re_abc123def456...`)

### 2. Domain Verification
Choose ONE:

#### Option A: Your School Domain
- [ ] In Resend: Domains → Add Domain
- [ ] Enter your domain (e.g., example.edu)
- [ ] Copy DNS records (DKIM, SPF)
- [ ] Add to your domain's DNS settings
- [ ] Wait for verification (5-30 mins)

#### Option B: Resend Test Domain (Quick Testing)
- [ ] Use: `onboarding@resend.dev`
- [ ] No setup needed
- [ ] Limit: 50 emails/day
- [ ] Perfect for testing before production

### 3. Update .env.local
```bash
RESEND_API_KEY=re_your_api_key_here
EMAIL_FROM=SchoolCentral <approvals@example.edu>
SITE_URL=http://localhost:3000
```

### 4. Test It
In SchoolCentral:
1. Sign up as Student
2. Go to account settings → Applications
3. Fill out representative application
4. Select a teacher from dropdown
5. Click "Submit application"
6. Check your email (teacher's email will receive approval link)

## What Gets Emailed?

### Teacher Approval Email
**Sent to:** Teacher
**Content:** Application details + approval link
**Example:** "Sam Rivera has applied to represent Robotics Club. Click here to approve or decline."

### Owner Notification Email
**Sent to:** School Owner
**Content:** "Teacher-approved application awaits you"
**Example:** "Sam Rivera's Robotics Club application has been approved by their teacher. Sign in to SchoolCentral to make final decision."

### Event Reminders
**Sent to:** Students enrolled in events
**Content:** Event details + time remaining
**Timing:** Configurable (5 min to 24 hours before event)
**Example:** "Robotics Club Meeting starts in 24 hours at Innovation Lab"

## Pricing
- Free tier: 100 emails/day
- Pay-as-you-go: $0.20 per email after free tier
- No monthly subscription

## Troubleshooting

### "Email could not be delivered"
- Check API key is correct in .env.local
- Verify domain in Resend dashboard
- Make sure SITE_URL is set to your app URL
- Restart dev server after env changes

### Domain verification failing
- Check DNS records are added correctly
- Wait 30+ mins (DNS can be slow)
- Use propagation checker: https://dnschecker.org

### Test emails not arriving
- Check spam/junk folder
- If using onboarding@resend.dev, you're limited to 50/day
- Verify EMAIL_FROM matches your sender domain

## Production Deployment Checklist
- [ ] Verified domain in Resend
- [ ] RESEND_API_KEY set in production env
- [ ] SITE_URL set to production HTTPS domain
- [ ] EMAIL_FROM uses verified domain
- [ ] Supabase project set up with migrations
- [ ] Background scheduler configured
- [ ] Test full email workflow with real teacher

## Next: Supabase Setup
Once Resend is working, you'll need Supabase for:
- Real user accounts (not just browser storage)
- Permanent data storage
- Email queue management
- RLS security policies
- See SUPABASE-SETUP.md for instructions

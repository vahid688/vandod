# SchoolCentral Database Schema Migration

## Goal
Apply the database schema to your Supabase project by executing `supabase/install-fresh.sql`.

## Prerequisites
- ✓ Supabase project created (`schoolcentral`)
- ✓ Environment variables configured in `.env.local`
- ✓ Supabase SQL Editor open and authenticated

## Quick Start (3 Steps)

### Step 1: Open the SQL file in your editor
```
C:\git\vandod\SchoolCentral\supabase\install-fresh.sql
```

Open this file in:
- Notepad
- VS Code
- Any text editor

The file contains 22,985 bytes of SQL code that will:
- Create database schema (tables, types, functions)
- Set up Row-Level Security (RLS) policies
- Create indexes and triggers
- Initialize configuration

### Step 2: Copy the entire SQL content

**Option A: Direct Copy**
- Select all content: `Ctrl+A`
- Copy: `Ctrl+C`

**Option B: Via Command Line**
```powershell
# This copies the full SQL to your clipboard
$sql = Get-Content "C:\git\vandod\SchoolCentral\supabase\install-fresh.sql" -Raw
$sql | Set-Clipboard
```

### Step 3: Paste into Supabase SQL Editor and Execute

1. Go to Supabase Dashboard → SQL Editor
2. You should see an editor with your previous test query
3. Click in the editor textarea
4. Select all existing content: `Ctrl+A`
5. Delete: `Delete` or `Backspace`
6. Paste the SQL: `Ctrl+V`
7. Click the **"Run"** button
8. Wait for execution to complete (~10-30 seconds)

## Expected Result

After successful execution, you should see:
- No error messages
- A success message or empty result set
- The SQL Editor remains open and responsive
- Status shows query executed successfully

## Troubleshooting

### "Already exists" Error
```
ERROR: SchoolCentral already exists. Apply pending migrations instead.
```
**Solution**: This means the schema was already partially created. This is a safety check.

### "Permission denied" Error
```
ERROR: permission denied for schema public
```
**Solution**: This shouldn't happen - your service role key should have full access. Check:
- You're logged into the correct Supabase account
- You're in the correct `schoolcentral` project
- Verify in Supabase Settings → API Keys that your keys match `.env.local`

### Timeout or "Connection lost" Error
**Solution**: The script is large (22KB). Supabase may need time to process. Refresh the page and check if the schema was created anyway by running:
```sql
select to_regclass('public.profiles');
```

### Paste Not Working
**Solution**: The SQL Editor may not accept large pastes via Ctrl+V. Try:
1. Use the Supabase CLI (see Alternative Method below)
2. Split the SQL into chunks manually (first 5KB, then next 5KB, etc.)
3. Open `install-fresh.sql` directly in your editor and copy smaller sections

## Alternative Method: Supabase CLI

If manual paste doesn't work, use the Supabase CLI (installed locally):

```bash
cd C:\git\vandod\SchoolCentral

# Link to your project
supabase link --project-ref tklowdvtasdnkodvxpiy

# You'll be prompted to enter your Supabase password

# Then push migrations
supabase db push

# Verify
supabase db tables
```

Note: The CLI uses your `.supabase/config.toml` file which is created during `supabase link`.

## Verify Schema Creation

After successful migration, verify by running this test query in Supabase SQL Editor:

```sql
-- Test 1: Verify tables exist
SELECT 
  'profiles' as table_name, 
  to_regclass('public.profiles') IS NOT NULL as exists;

-- Test 2: Count all tables created
SELECT COUNT(*) as table_count 
FROM information_schema.tables 
WHERE table_schema='public';

-- Test 3: List all new tables
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema='public'
ORDER BY table_name;

-- Test 4: Check RLS is enabled
SELECT tablename 
FROM pg_tables 
WHERE schemaname='public'
AND tablename IN ('profiles', 'user_roles', 'events')
ORDER BY tablename;
```

Expected results:
- Test 1: `profiles` table should exist (`t` = true)
- Test 2: Should show ~8 tables created
- Test 3: Should list: categories, events, favorites, organization_representatives, organizations, profiles, settings, user_roles
- Test 4: All shown tables should have RLS enabled

## Next Steps (After Schema Creation)

1. **Bootstrap Owner Account** - Your account will be created as a `Student`. Run this SQL:
   ```sql
   -- First, sign up in the app with vnnamazi@gmail.com
   -- Then find your UUID in Auth → Users
   -- Then run this:
   update public.user_roles
   set role = 'Owner'
   where user_id = 'YOUR_USER_UUID'::uuid;
   ```

2. **Restart Dev Server**
   ```bash
   pnpm dev
   ```

3. **Test Real Backend**
   - Navigate to http://localhost:3000
   - You should be able to log in with real authentication
   - No more "Backend setup required" message
   - Demo buttons should be gone (real auth only)

4. **Test Representative Application Workflow**
   - Log in as Student (create new account)
   - Navigate to Account Settings → Apply for Representative
   - Submit an application
   - You should receive an email via Resend
   - Teacher can click approval link

## Files Referenced

- Schema: `supabase/install-fresh.sql` (23 KB)
- Config: `.env.local` (Supabase credentials)
- Migration status: Tracked in Supabase project dashboard

## Need Help?

If you get stuck:
1. Check the error message carefully - it usually describes the problem
2. Verify your Supabase credentials in `.env.local`
3. Try running a simple test query first: `select now();`
4. Check Supabase project status on their dashboard
5. Look at browser console for any network errors (F12 → Network tab)

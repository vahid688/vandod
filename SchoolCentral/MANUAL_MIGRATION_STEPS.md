# Manual Migration Instructions - Quick Copy-Paste Guide

Since automated application is having issues, please follow these simple copy-paste steps:

## Quick Summary

You need to run 2 SQL queries in Supabase to:
1. Add CASCADE DELETE to foreign keys (fixes organization deletion)
2. Add RLS policies and database function (fixes Cancel Application)

## Step 1: Open Supabase SQL Editor

1. Go to https://supabase.com/dashboard
2. Select your **schoolcentral** project
3. Click **SQL Editor** in the left sidebar
4. Click **New Query** (or clear the existing editor)

## Step 2: Run CASCADE DELETE Migration

Copy and paste **THIS ENTIRE BLOCK** into the SQL editor:

```sql
-- Cascade Delete Migration
ALTER TABLE representative_applications 
DROP CONSTRAINT representative_applications_organization_id_fkey;

ALTER TABLE representative_applications 
ADD CONSTRAINT representative_applications_organization_id_fkey 
FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

ALTER TABLE organization_representatives 
DROP CONSTRAINT IF EXISTS organization_representatives_organization_id_fkey;

ALTER TABLE organization_representatives 
ADD CONSTRAINT organization_representatives_organization_id_fkey 
FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;
```

Then click **Run** button (or press Ctrl+Enter)

**Expected Result:** You should see "0 rows" in the results, no errors. This means success!

---

## Step 3: Run RLS Policies & Database Function Migration

Click **New Query** to create a new query tab, then copy and paste **THIS ENTIRE BLOCK**:

```sql
-- RLS Policies Migration
CREATE POLICY "Users can delete their own applications" ON representative_applications
  FOR DELETE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can view their own applications" ON representative_applications
  FOR SELECT
  USING (auth.uid() = user_id 
    OR (SELECT role FROM user_roles WHERE user_id = auth.uid()) = 'Owner');

CREATE POLICY "Users can create their own applications" ON representative_applications
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Database Function for Safe Application Deletion
CREATE OR REPLACE FUNCTION delete_user_application(application_id UUID)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_application_id UUID;
  v_user_id UUID;
BEGIN
  v_user_id := auth.uid();
  
  SELECT id INTO v_application_id
  FROM representative_applications
  WHERE id = application_id AND user_id = v_user_id;
  
  IF v_application_id IS NULL THEN
    RETURN json_build_object('error', 'Application not found or does not belong to user');
  END IF;
  
  DELETE FROM representative_applications
  WHERE id = application_id AND user_id = v_user_id;
  
  RETURN json_build_object('message', 'Application cancelled successfully');
END;
$$;
```

Then click **Run** button (or press Ctrl+Enter)

**Expected Result:** You should see "0 rows" in the results, no errors. This means success!

---

## Step 4: Test the Fixes

After running both migrations:

1. **Test Cancel Application:**
   - Go to http://127.0.0.1:3001/
   - Click your account settings (top right)
   - Click "Apply for Representative"
   - Find your pending application (Robotics Club)
   - Click "Cancel application"
   - Confirm the dialog
   - The application should disappear from your list

2. **Test Organization Deletion:**
   - Go to http://127.0.0.1:3001/ as Owner
   - Go to Owner Dashboard
   - Click Organizations tab
   - Try to delete an organization
   - It should now delete successfully without FK errors

---

## Troubleshooting

If you see an error:

- **"permission denied for table"** → Run the RLS migration again
- **"syntax error"** → Make sure you copied the entire SQL block correctly without truncating it
- **"constraint already exists"** → The migration already ran successfully, it's safe to run again

## Files Reference

- [migrations/fix-cascade-delete.sql] - Contains the CASCADE DELETE SQL
- [migrations/fix-representative-applications-rls.sql] - Contains the RLS and function SQL

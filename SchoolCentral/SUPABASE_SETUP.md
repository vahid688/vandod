# Supabase Setup Instructions

## 1. Foreign Key Cascade Delete Fix

The database currently has a foreign key constraint that prevents organizations from being deleted if they have related `representative_applications` records.

### Option 1: Run SQL Migration (Recommended)

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Click **New Query**
4. Copy and paste the entire content of `migrations/fix-cascade-delete.sql`
5. Click **Run**

This will modify the foreign key constraints to automatically delete related records when an organization is deleted.

### Option 2: Manual SQL Execution

If you prefer to run the SQL commands individually:

```sql
-- Drop the existing constraint
ALTER TABLE representative_applications 
DROP CONSTRAINT representative_applications_organization_id_fkey;

-- Add it back with CASCADE DELETE
ALTER TABLE representative_applications 
ADD CONSTRAINT representative_applications_organization_id_fkey 
FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- Do the same for organization_representatives
ALTER TABLE organization_representatives 
DROP CONSTRAINT IF EXISTS organization_representatives_organization_id_fkey;

ALTER TABLE organization_representatives 
ADD CONSTRAINT organization_representatives_organization_id_fkey 
FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;
```

---

## 2. Representative Applications RLS Policy & Database Function

Users need permission to delete their own applications. This requires updating the Row Level Security (RLS) policies and creating a database function to safely handle the deletion.

### Run SQL Migration

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**
3. Click **New Query**
4. Copy and paste the content of `migrations/fix-representative-applications-rls.sql`
5. Click **Run**

### What This Does

This migration:
- Creates RLS policies to allow users to view and delete only their own applications
- Creates a database function `delete_user_application()` marked with `SECURITY DEFINER` that safely validates ownership and deletes applications
- Uses the function instead of direct table deletion, which is safer and bypasses RLS restrictions for server-side operations

### Manual SQL Execution

If you prefer to run the SQL commands individually, see the content of `migrations/fix-representative-applications-rls.sql` for the complete commands.

---

## Testing the Fixes

After running both migrations:

1. **Test Organization Deletion:**
   - Go to Owner Dashboard
   - Navigate to Organizations tab
   - Click Delete on any organization
   - The organization and all its related records should delete successfully

2. **Test Application Cancellation:**
   - Go to Account Settings
   - Click "Apply for Representative"
   - Create or find a pending application
   - Click "Cancel application"
   - Confirm the cancellation
   - The application should be removed from your list

## Why These Fixes Are Needed

- **Cascade Delete**: PostgreSQL foreign key constraints prevent deletion if there are dependent records. By adding `ON DELETE CASCADE`, we tell the database to automatically delete dependent records when the parent record is deleted.

- **RLS Policies**: Supabase uses Row Level Security to protect data access. By default, users may not have permission to delete records in certain tables. The DELETE policy allows users to delete only their own records while protecting others' data.


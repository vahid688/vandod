-- This migration fixes the foreign key constraint to use CASCADE DELETE
-- This allows organizations to be deleted even if they have related records

-- Step 1: Drop the existing foreign key constraint
ALTER TABLE representative_applications 
DROP CONSTRAINT representative_applications_organization_id_fkey;

-- Step 2: Add the constraint back with ON DELETE CASCADE
ALTER TABLE representative_applications 
ADD CONSTRAINT representative_applications_organization_id_fkey 
FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- Step 3: Also add CASCADE for organization_representatives if it has the same issue
-- First check if the constraint exists, then modify if needed
ALTER TABLE organization_representatives 
DROP CONSTRAINT IF EXISTS organization_representatives_organization_id_fkey;

ALTER TABLE organization_representatives 
ADD CONSTRAINT organization_representatives_organization_id_fkey 
FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

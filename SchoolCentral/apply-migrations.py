#!/usr/bin/env python3
"""
Script to apply Supabase database migrations via the REST API
"""

import requests
import json
import sys

# Supabase credentials
SUPABASE_URL = "https://tklowdvtasdnkodvxpiy.supabase.co"
SUPABASE_SERVICE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRrbG93ZHZ0YXNkbmtvZHZ4aXkiLCJyb2xlIjoic2VydmljZV9yb2xlIiwiaWF0IjoxNzI1MzI1NjMyLCJleHAiOjE4ODI5OTE2MzJ9.Yp9fBBwZKKzuDfZ2qGnD9x8GiR3D7wMsP8XK0d5xqrY"

# Headers for API requests
headers = {
    "Authorization": f"Bearer {SUPABASE_SERVICE_KEY}",
    "Content-Type": "application/json",
    "apikey": SUPABASE_SERVICE_KEY
}

# SQL Migrations
MIGRATION_1 = """
-- Add CASCADE DELETE to representative_applications
ALTER TABLE representative_applications 
DROP CONSTRAINT representative_applications_organization_id_fkey;

ALTER TABLE representative_applications 
ADD CONSTRAINT representative_applications_organization_id_fkey 
FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

-- Add CASCADE DELETE to organization_representatives
ALTER TABLE organization_representatives 
DROP CONSTRAINT IF EXISTS organization_representatives_organization_id_fkey;

ALTER TABLE organization_representatives 
ADD CONSTRAINT organization_representatives_organization_id_fkey 
FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;
"""

MIGRATION_2 = """
-- Enable RLS policies for representative_applications table
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

-- Create a database function to safely delete applications
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
  
  -- Verify the application belongs to the current user
  SELECT id INTO v_application_id
  FROM representative_applications
  WHERE id = application_id AND user_id = v_user_id;
  
  IF v_application_id IS NULL THEN
    RETURN json_build_object('error', 'Application not found or does not belong to user');
  END IF;
  
  -- Delete the application
  DELETE FROM representative_applications
  WHERE id = application_id AND user_id = v_user_id;
  
  RETURN json_build_object('message', 'Application cancelled successfully');
END;
$$;
"""

def execute_migration(migration_sql, migration_name):
    """Execute a SQL migration via Supabase REST API"""
    print(f"\n{'='*60}")
    print(f"Executing: {migration_name}")
    print(f"{'='*60}")
    
    # Use the PostgreSQL connection via REST API
    url = f"{SUPABASE_URL}/rest/v1/rpc/exec_sql"
    
    payload = {
        "query": migration_sql
    }
    
    try:
        response = requests.post(url, json=payload, headers=headers)
        
        if response.status_code in [200, 201]:
            print(f"✓ {migration_name} executed successfully!")
            print(f"Response: {response.text}")
            return True
        else:
            print(f"✗ Error executing {migration_name}")
            print(f"Status Code: {response.status_code}")
            print(f"Response: {response.text}")
            return False
    except Exception as e:
        print(f"✗ Exception while executing {migration_name}: {str(e)}")
        return False

def main():
    print("SchoolCentral Supabase Migration Script")
    print("="*60)
    
    # Execute migrations
    results = []
    
    print("\n[Step 1/2] Applying CASCADE DELETE migration...")
    results.append(execute_migration(MIGRATION_1, "CASCADE DELETE Migration"))
    
    print("\n[Step 2/2] Applying RLS Policies and Database Function migration...")
    results.append(execute_migration(MIGRATION_2, "RLS Policies & Database Function Migration"))
    
    # Summary
    print(f"\n{'='*60}")
    print("Migration Summary:")
    print(f"{'='*60}")
    if all(results):
        print("✓ All migrations executed successfully!")
        return 0
    else:
        print("✗ Some migrations failed. Please check the output above.")
        return 1

if __name__ == "__main__":
    sys.exit(main())

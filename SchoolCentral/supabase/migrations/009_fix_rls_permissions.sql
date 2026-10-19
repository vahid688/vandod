-- Add RLS policies for user_roles and organization_representatives

-- Create UPDATE policy for user_roles to allow Owner to manage roles
CREATE POLICY IF NOT EXISTS "roles_update_owner" ON public.user_roles
  FOR UPDATE TO authenticated
  USING (public.is_owner())
  WITH CHECK (public.is_owner());

-- Create INSERT policy for organization_representatives to allow Owners to assign
CREATE POLICY IF NOT EXISTS "assignments_insert_owner" ON public.organization_representatives
  FOR INSERT TO authenticated
  WITH CHECK (public.is_owner());

-- Create UPDATE policy for organization_representatives 
CREATE POLICY IF NOT EXISTS "assignments_update_owner" ON public.organization_representatives
  FOR UPDATE TO authenticated
  USING (public.is_owner())
  WITH CHECK (public.is_owner());

-- Create DELETE policy for organization_representatives
CREATE POLICY IF NOT EXISTS "assignments_delete_owner" ON public.organization_representatives
  FOR DELETE TO authenticated
  USING (public.is_owner());


-- Enable RLS policies for representative_applications table

-- Policy to allow users to DELETE their own applications
CREATE POLICY "Users can delete their own applications" ON representative_applications
  FOR DELETE
  USING (auth.uid() = user_id);

-- Policy to allow users to SELECT their own applications
CREATE POLICY "Users can view their own applications" ON representative_applications
  FOR SELECT
  USING (auth.uid() = user_id 
    OR (SELECT role FROM user_roles WHERE user_id = auth.uid()) = 'Owner');

-- Policy to allow users to INSERT their own applications
CREATE POLICY "Users can create their own applications" ON representative_applications
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Create a database function to safely delete an application
-- This function includes proper user ownership validation
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

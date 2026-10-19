-- Fix review_teacher_application to handle duplicate org names gracefully
DROP FUNCTION IF EXISTS public.review_teacher_application(text, boolean);

CREATE FUNCTION public.review_teacher_application(hash text, approve boolean) 
RETURNS void 
LANGUAGE plpgsql 
SECURITY DEFINER 
SET search_path='' AS $$
DECLARE 
  token public.teacher_approval_tokens; 
  application public.representative_applications; 
  chosen uuid;
BEGIN
  SELECT * INTO token FROM public.teacher_approval_tokens WHERE token_hash=hash FOR UPDATE;
  IF NOT FOUND OR token.used_at IS NOT NULL OR token.expires_at<=now() THEN 
    RAISE EXCEPTION 'This approval link is expired or already used';
  END IF;
  
  SELECT * INTO application FROM public.representative_applications WHERE id=token.application_id FOR UPDATE;
  IF application.status<>'pending_teacher' OR NOT EXISTS(SELECT 1 FROM public.approved_teachers WHERE email=application.teacher_email) THEN 
    RAISE EXCEPTION 'This application is no longer eligible for teacher review';
  END IF;
  
  UPDATE public.teacher_approval_tokens SET used_at=now() WHERE application_id=application.id;
  
  IF approve THEN
    IF NOT EXISTS(SELECT 1 FROM public.profiles WHERE id=application.user_id AND active) THEN 
      RAISE EXCEPTION 'Applicant account is disabled';
    END IF;
    IF EXISTS(SELECT 1 FROM public.user_roles WHERE user_id=application.user_id AND role='Owner') THEN 
      RAISE EXCEPTION 'Cannot modify Owner';
    END IF;
    
    -- Try to get existing org with same name, or create new one
    SELECT id INTO chosen FROM public.organizations WHERE name=application.club_name LIMIT 1;
    IF chosen IS NULL THEN
      INSERT INTO public.organizations(name,description) VALUES(application.club_name,application.description) 
      ON CONFLICT(name) DO UPDATE SET description=EXCLUDED.description RETURNING id INTO chosen;
    END IF;
    
    UPDATE public.user_roles SET role='Representative' WHERE user_id=application.user_id;
    INSERT INTO public.organization_representatives(user_id,organization_id) VALUES(application.user_id,chosen) ON CONFLICT DO NOTHING;
    UPDATE public.representative_applications SET status='approved',teacher_reviewed_at=now(),organization_id=chosen WHERE id=application.id;
  ELSE
    UPDATE public.representative_applications SET status='teacher_rejected',teacher_reviewed_at=now() WHERE id=application.id;
  END IF;
END$$;

GRANT EXECUTE ON FUNCTION public.review_teacher_application(text, boolean) TO service_role;

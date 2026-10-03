-- Add 'accepted' status to representative applications
-- Allows applications to be marked as accepted after the user clicks the button

ALTER TABLE public.representative_applications
DROP CONSTRAINT representative_applications_status_check;

ALTER TABLE public.representative_applications
ADD CONSTRAINT representative_applications_status_check 
CHECK (status IN ('pending_teacher','teacher_approved','teacher_rejected','approved','rejected','accepted'));

import {NextResponse} from 'next/server';
import {createClient} from '@supabase/supabase-js';
import {validateApplication} from '@/domain/applications';
import {authenticatedClient,mailConfigured,sendTeacherEmail} from '@/server/application-service';

export async function POST(request:Request){try{const client=await authenticatedClient(request);const input=await request.json();

// Handle application cancellation
if(input.cancel_id){
  // Get the user ID from the authenticated client
  const {data:{user}}=await client.auth.getUser();
  if(!user)throw Error('Not authenticated');
  
  // Use service role client to bypass RLS for the delete operation
  const serviceClient=createClient(process.env.NEXT_PUBLIC_SUPABASE_URL!,process.env.SUPABASE_SERVICE_ROLE_KEY!);
  
  // First verify the application belongs to the user
  const {data:application,error:fetchError}=await client.from('representative_applications').select('*').eq('id',input.cancel_id).single();
  if(fetchError||!application||application.user_id!==user.id)throw Error('Application not found or does not belong to user');
  
  // Delete the application using service role
  const {error:deleteError}=await serviceClient.from('representative_applications').delete().eq('id',input.cancel_id);
  if(deleteError)throw Error(deleteError.message||'Unable to cancel application');
  
  return NextResponse.json({message:'Application cancelled.'});
}

if(process.env.NEXT_PUBLIC_DEMO_MODE==='true')return NextResponse.json({error:'Email is disabled in local demo.'},{status:400});

mailConfigured();

if(input.resend_id){const {data:application,error}=await client.from('representative_applications').select('*').eq('id',input.resend_id).single();const {data:user}=await client.auth.getUser();if(error||!application||application.user_id!==user.user?.id||application.status!=='pending_teacher')throw Error('Application is unavailable.');await sendTeacherEmail(application.id);return NextResponse.json({message:'Teacher approval email sent.'});}

const values={club_name:String(input.club_name||'').trim(),description:String(input.description||'').trim(),teacher_email:String(input.teacher_email||'').trim().toLowerCase()};validateApplication(values);const {data:id,error}=await client.rpc('submit_representative_application',{club:values.club_name,brief:values.description,teacher:values.teacher_email});if(error)throw error;try{await sendTeacherEmail(id)}catch{return NextResponse.json({message:'Application saved, but email delivery failed. Use Resend teacher email to retry.',application_id:id,delivery_failed:true},{status:202})}return NextResponse.json({message:'Application submitted. Your teacher has been emailed.',application_id:id});}catch(error){return NextResponse.json({error:error instanceof Error?error.message:typeof error==='object'&&error&&'message' in error?String(error.message):'Application could not be submitted.'},{status:400})}}




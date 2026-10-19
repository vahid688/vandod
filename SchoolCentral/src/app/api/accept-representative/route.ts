import {NextResponse} from 'next/server';
import {authenticatedClient,adminClient} from '@/server/application-service';

export async function POST(request:Request){
  try {
    const authClient=await authenticatedClient(request);
    const adminCli=adminClient();
    const input=await request.json();
    
    if(typeof input.application_id!=='string')throw Error('Application ID required.');
    
    const {data:user}=await authClient.auth.getUser();
    if(!user.user)throw Error('Authentication required.');
    
    const {data:application,error:appError}=await authClient.from('representative_applications')
      .select('*').eq('id',input.application_id).eq('user_id',user.user.id).single();
    if(appError||!application||!['approved','teacher_approved'].includes(application.status))
      throw Error('Application is not eligible for acceptance.');
    
    const {data:profile}=await adminCli.from('profiles').select('role').eq('id',user.user.id).single();
    if(profile?.role==='Representative')
      return NextResponse.json({message:'Your account is already a Representative.'});
    
    const {error:roleError}=await adminCli.from('user_roles')
      .update({role:'Representative'}).eq('user_id',user.user.id);
    if(roleError)throw roleError;
    
    let organizationId=application.organization_id;
    
    // If organization_id is set, verify it exists (in case it was deleted)
    if(organizationId){
      const {data:org}=await adminCli.from('organizations').select('id').eq('id',organizationId).maybeSingle();
      if(!org){
        organizationId=null;
      }
    }
    
    // If no valid organization_id, create or find one
    if(!organizationId){
      const {data:existing}=await adminCli.from('organizations')
        .select('id').eq('name',application.club_name).maybeSingle();
      organizationId=existing?.id;
      
      if(!organizationId){
        const {data:org,error:orgError}=await adminCli.from('organizations')
          .insert({name:application.club_name,description:application.description})
          .select('id').single();
        if(orgError)throw orgError;
        organizationId=org.id;
      }
      
      const {error:updateAppError}=await adminCli.from('representative_applications')
        .update({organization_id:organizationId}).eq('id',input.application_id);
      if(updateAppError)throw updateAppError;
    }
    
    const {error:assignError}=await adminCli.from('organization_representatives')
      .upsert({user_id:user.user.id,organization_id:organizationId},{onConflict:'user_id,organization_id'});
    if(assignError)throw assignError;
    
    const {error:statusError}=await adminCli.from('representative_applications')
      .update({status:'accepted'}).eq('id',input.application_id);
    if(statusError)throw statusError;
    
    return NextResponse.json({message:'Congratulations! Your account has been upgraded to Representative.'});
    
  }catch(error){
    return NextResponse.json({error:error instanceof Error?error.message:'Could not accept representative role.'},{status:400});
  }
}

import {NextResponse} from 'next/server';
import {authenticatedClient, adminClient} from '@/server/application-service';

export async function GET(request:Request){
  try {
    const authClient = await authenticatedClient(request);
    const adminCli = adminClient();
    
    const {data:user} = await authClient.auth.getUser();
    if(!user.user) throw Error('Not authenticated');
    
    // Get user's applications
    const {data:applications} = await adminCli.from('representative_applications')
      .select('*').eq('user_id', user.user.id);
    
    // Get user's role
    const {data:role} = await adminCli.from('user_roles')
      .select('*').eq('user_id', user.user.id).single();
    
    // Get user's organization links
    const {data:links} = await adminCli.from('organization_representatives')
      .select('*').eq('user_id', user.user.id);
    
    // Get organizations
    const {data:orgs} = await adminCli.from('organizations').select('*');
    
    return NextResponse.json({
      userId: user.user.id,
      applications: applications || [],
      role: role?.role,
      organizationLinks: links || [],
      allOrganizations: orgs || []
    });
    
  } catch(error) {
    return NextResponse.json({error: error instanceof Error ? error.message : 'Error'}, {status: 400});
  }
}

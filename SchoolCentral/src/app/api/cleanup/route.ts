import {NextRequest,NextResponse} from 'next/server';
import {createClient} from '@supabase/supabase-js';

export async function POST(request:NextRequest){
  try {
    const auth=request.headers.get('authorization');
    const expectedToken=process.env.CLEANUP_TOKEN||'cleanup-token-dev';
    
    if(auth!==`Bearer ${expectedToken}`){
      return NextResponse.json({error:'Unauthorized'},{status:401});
    }

    const url=process.env.NEXT_PUBLIC_SUPABASE_URL;
    const serviceKey=process.env.SUPABASE_SERVICE_ROLE_KEY;
    
    if(!url||!serviceKey){
      return NextResponse.json({error:'Missing environment variables'},{status:500});
    }

    const db=createClient(url,serviceKey);
    
    // Delete all representative applications
    const {error}=await db
      .from('representative_applications')
      .delete()
      .gte('created_at','1900-01-01');
    
    if(error) throw error;
    
    return NextResponse.json({success:true,message:'All applications deleted'});
  }catch(error){
    console.error('Cleanup error:',error);
    return NextResponse.json(
      {error:error instanceof Error?error.message:'Unknown error'},
      {status:500}
    );
  }
}

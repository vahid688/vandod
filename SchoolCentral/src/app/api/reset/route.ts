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
    
    // Delete all organization representative assignments
    await db.rpc('exec',{query:'DELETE FROM public.organization_representatives;'}).then(r=>{if(r.error) throw r.error;});
    
    // Revert ALL representatives to Student
    await db.rpc('exec',{query:"UPDATE public.user_roles SET role='Student' WHERE role='Representative';"}).then(r=>{if(r.error) throw r.error;});
    
    return NextResponse.json({success:true,message:'All representatives reverted to Student status'});
  }catch(error){
    console.error('Reset error:',error);
    return NextResponse.json(
      {error:error instanceof Error?error.message:'Unknown error'},
      {status:500}
    );
  }
}

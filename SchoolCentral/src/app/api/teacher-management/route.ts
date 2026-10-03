import {NextResponse} from 'next/server';
import {authenticatedClient} from '@/server/application-service';

export async function POST(request:Request){
  try{
    const client=await authenticatedClient(request);
    const {data:user,error:userError}=await client.auth.getUser();
    if(userError||!user.user)throw Error('Sign in first.');

    const {data:profile}=await client.from('profiles').select('role').eq('id',user.user.id).single();
    if(!profile||profile.role!=='Owner')throw Error('Only Owner can manage teachers.');

    const input=await request.json();
    if(!['add','remove'].includes(input.action))throw Error('Invalid action.');
    if(typeof input.email!=='string'||!input.email.includes('@'))throw Error('Invalid email address.');

    const email=input.email.toLowerCase();

    if(input.action==='add'){
      const {error}=await client.from('approved_teachers').insert({email});
      if(error){
        if(error.code==='23505')throw Error('This teacher email is already authorized.');
        throw error;
      }
      return NextResponse.json({success:true});
    }else{
      const {error}=await client.from('approved_teachers').delete().eq('email',email);
      if(error)throw error;
      return NextResponse.json({success:true});
    }
  }catch(error){
    return NextResponse.json({error:error instanceof Error?error.message:'Failed to update teacher.'},
      {status:400});
  }
}

import {NextResponse} from 'next/server';
import {authenticatedClient,sendOwnerNotifications} from '@/server/application-service';
export async function POST(request:Request){try{if(process.env.NEXT_PUBLIC_DEMO_MODE==='true')return NextResponse.json({error:'Email is disabled in local demo.'},{status:400});const client=await authenticatedClient(request);const {data,error}=await client.rpc('is_owner');if(error||!data)return NextResponse.json({error:'Owner required.'},{status:403});await sendOwnerNotifications();return NextResponse.json({ok:true})}catch{return NextResponse.json({error:'Pending emails will be retried next time the Owner opens Applications.'},{status:503})}}


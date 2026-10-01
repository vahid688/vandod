import {NextResponse} from 'next/server';
import {timingSafeEqual} from 'node:crypto';
import {adminClient,sendMail,siteUrl} from '@/server/application-service';
export async function POST(request:Request){
 const secret=process.env.NOTIFICATION_JOB_SECRET;
 const received=request.headers.get('authorization')||'';
 const expected=`Bearer ${secret}`;
 if(!secret||received.length!==expected.length||!timingSafeEqual(Buffer.from(received),Buffer.from(expected)))return NextResponse.json({error:'Unauthorized'},{status:401});
 if(process.env.NEXT_PUBLIC_DEMO_MODE==='true')return NextResponse.json({error:'Demo email delivery is disabled.'},{status:400});
 try{
  const admin=adminClient();const now=Date.now();
  const {data:events,error:eventsError}=await admin.from('events').select('id,title,starts_at,location').eq('status','published').gt('starts_at',new Date(now).toISOString()).lte('starts_at',new Date(now+24*3600000).toISOString());if(eventsError)throw eventsError;
  for(const event of events||[]){
   const {data:enrollments,error}=await admin.from('favorites').select('user_id').eq('event_id',event.id);if(error)throw error;
   for(const enrollment of enrollments||[]){const {data:preference,error:preferenceError}=await admin.from('notification_preferences').select('reminders,reminder_minutes').eq('user_id',enrollment.user_id).maybeSingle();if(preferenceError)throw preferenceError;if(!preference?.reminders||Date.parse(event.starts_at)-now>preference.reminder_minutes*60000)continue;const {error:queueError}=await admin.from('event_email_queue').upsert({user_id:enrollment.user_id,event_id:event.id,kind:'reminder',title:event.title,starts_at:event.starts_at,location:event.location,version:event.starts_at},{onConflict:'user_id,event_id,kind,version',ignoreDuplicates:true});if(queueError)throw queueError;}
  }
  const {data:queue,error}=await admin.from('event_email_queue').select('*').is('sent_at',null).order('version').limit(100);if(error)throw error;
  let sent=0;
  for(const item of queue||[]){
   const {data:profile,error:profileError}=await admin.from('profiles').select('active').eq('id',item.user_id).maybeSingle();if(profileError)throw profileError;
   const {data:preferences,error:preferencesError}=await admin.from('notification_preferences').select('*').eq('user_id',item.user_id).maybeSingle();if(preferencesError)throw preferencesError;
   const {data:enrollment,error:enrollmentError}=await admin.from('favorites').select('user_id').eq('user_id',item.user_id).eq('event_id',item.event_id).maybeSingle();if(enrollmentError)throw enrollmentError;
   let eligible=profile?.active&&preferences&&(item.kind==='reminder'?preferences.reminders:preferences.changes)&&(item.kind==='cancelled'||enrollment);
   if(item.kind==='reminder'){const {data:event,error:eventError}=await admin.from('events').select('starts_at,status').eq('id',item.event_id).maybeSingle();if(eventError)throw eventError;eligible=eligible&&event?.status==='published'&&event.starts_at===item.starts_at&&Date.parse(item.starts_at)>now;if(eligible&&Date.parse(item.starts_at)-now>preferences!.reminder_minutes*60000)continue;}
   if(eligible){await sendMail(preferences!.email,`SchoolCentral: ${item.kind==='reminder'?'Reminder':item.kind==='cancelled'?'Event cancelled':'Event updated'} — ${item.title}`,`${item.title}\n${item.kind==='cancelled'?'This event has been cancelled or is no longer published.':`Starts: ${new Date(item.starts_at).toUTCString()}\nLocation: ${item.location}`}\n\nOpen SchoolCentral for details: ${siteUrl()}\nManage email preferences in Settings → Notifications.`,item.id);sent++;}
   const {error:markError}=await admin.from('event_email_queue').update({sent_at:new Date().toISOString()}).eq('id',item.id);if(markError)throw markError;
  }
  return NextResponse.json({sent});
 }catch{return NextResponse.json({error:'Email delivery failed; pending messages will be retried.'},{status:503});}
}

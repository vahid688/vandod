'use client';
import {Button} from './ui/button';
import {TeacherPicker} from './teacher-picker';
import {db,demo} from '@/data/supabase';
import {loadState} from '@/data/repository';
import {validateApplication} from '@/domain/applications';
import type {Profile,State,RepresentativeApplication} from '@/domain/types';

const labels:Record<RepresentativeApplication['status'],string>={
  pending_teacher:'Awaiting teacher approval',
  teacher_approved:'Approved · Representative access granted',
  teacher_rejected:'Declined by teacher',
  approved:'Approved · Representative access granted',
  rejected:'Declined by teacher'
};

type Props={
  state:State;
  user:Profile;
  setState:React.Dispatch<React.SetStateAction<State>>;
  run:(operation:()=>Promise<void>,message?:string)=>Promise<void>;
  busy:boolean
};

async function api(path:string,input:unknown){
  const {data}=await db!.auth.getSession();
  const response=await fetch(path,{
    method:'POST',
    headers:{
      'Content-Type':'application/json',
      Authorization:`Bearer ${data.session?.access_token||''}`
    },
    body:JSON.stringify(input)
  });
  const body=await response.json();
  if(!response.ok)throw Error(body.error||'Request failed.');
  return body;
}

export function ApplicationCenter({state,user,setState,run,busy}:Props){
  const applications=state.applications.filter(a=>a.user_id===user.id);
  return <>
    <div className="application-steps">
      <span>1. Your application</span>
      <span>2. Teacher approval</span>
    </div>
    <p>You keep your current permissions while your application is reviewed. A teacher will approve or decline your request.</p>
    <form className="settings-form application-form" onSubmit={event=>{
      event.preventDefault();
      const form=event.currentTarget,fields=new FormData(form);
      const input={
        club_name:String(fields.get('club_name')).trim(),
        description:String(fields.get('description')).trim(),
        teacher_email:String(fields.get('teacher_email')).trim().toLowerCase()
      };
      void run(async()=>{
        validateApplication(input);
        if(demo){
          if(!state.teachers.some(t=>t.email===input.teacher_email))
            throw Error('This teacher email is not authorized. Ask the Owner to add it first.');
          const application:RepresentativeApplication={
            id:crypto.randomUUID(),
            user_id:user.id,
            applicant_name:user.name,
            ...input,
            status:'pending_teacher',
            created_at:new Date().toISOString(),
            teacher_reviewed_at:null,
            owner_reviewed_at:null,
            organization_id:null
          };
          setState(s=>({...s,applications:[application,...s.applications]}));
        }else{
          const result=await api('/api/representative-applications',input);
          setState(await loadState());
          form.reset();
          if(result.delivery_failed)throw Error(result.message);
        }
        form.reset();
      },demo?'Demo application submitted. No email was sent.':'Application submitted. Check its status below.');
    }}>
      <label>Club or organization name
        <input name="club_name" required minLength={2} maxLength={120} placeholder="e.g. Robotics Club"/>
      </label>
      <label>Brief description
        <textarea name="description" required minLength={10} maxLength={1000} rows={4} placeholder="Describe your club and your role in it."/>
      </label>
      <TeacherPicker key={state.applications.length} teachers={state.teachers}/>
      <p className="form-help">Use a teacher email authorized by the Owner. The teacher receives a secure link to approve or decline your request.</p>
      {demo&&<p className="demo-note">Local demo: select an authorized teacher above. The teacher can simulate review under Applications. No actual email is sent.</p>}
      <Button disabled={busy}>Submit application</Button>
    </form>
    <div className="section-title"><h2>Your applications</h2></div>
    {applications.length===0?
      <div className="empty">
        <h3>No applications yet</h3>
        <p>Submit your club details above to get started.</p>
      </div>
    :
      applications.map(a=>
        <article className="application-card" key={a.id}>
          <span className="tag">{labels[a.status]}</span>
          <h3>{a.club_name}</h3>
          <p>{a.description}</p>
          <small>Teacher: {a.teacher_email} · Submitted {new Date(a.created_at).toLocaleDateString()}</small>
          {a.status==='pending_teacher'&&!demo&&
            <Button variant="outline" disabled={busy} onClick={()=>void run(async()=>{
              await api('/api/representative-applications',{resend_id:a.id})
            },'Teacher approval email sent.')}>Resend teacher email</Button>
          }
        </article>
      )
    }
  </>
}

export function OwnerApplications({state,user}:{state:State;user:Profile}){
  if(user.role!=='Owner')return null;
  const approved=state.applications.filter(a=>a.status==='teacher_approved'||a.status==='approved');
  return <>
    <div className="section-title"><h2>Approved representatives <span>{approved.length}</span></h2></div>
    <p>Teachers review and approve club applications directly. Once a teacher approves, the applicant gains Representative access immediately.</p>
    {approved.length===0?
      <div className="empty"><h3>No approved applications yet</h3></div>
    :
      approved.map(a=>
        <article className="application-card" key={a.id}>
          <span className="tag">{labels[a.status]}</span>
          <h3>{a.club_name}</h3>
          <p>{a.description}</p>
          <p><b>{a.applicant_name}</b> · {state.profiles.find(p=>p.id===a.user_id)?.email}</p>
          <small>Approved by teacher: {a.teacher_email}</small>
        </article>
      )
    }
  </>
}

export function TeacherDirectory({state,user,setState,run,busy}:Props){
  if(user.role!=='Owner')return null;
  return <>
    <div className="section-title"><h2>Authorized teachers <span>{state.teachers.length}</span></h2></div>
    <p>Add teacher emails to authorize them to review club applications.</p>
    <form className="inline-form" onSubmit={event=>{
      event.preventDefault();
      const form=event.currentTarget,fields=new FormData(form);
      const email=String(fields.get('email')).trim().toLowerCase();
      void run(async()=>{
        if(state.teachers.some(t=>t.email===email))throw Error('This teacher is already authorized.');
        if(demo){
          setState(s=>({...s,teachers:[...s.teachers,{email,name:email.split('@')[0]}]}));
        }else{
          const result=await api('/api/teacher-management',{action:'add',email});
          if(result.error)throw Error(result.error);
          setState(await loadState());
        }
        form.reset();
      },'Teacher email added.');
    }}>
      <input name="email" type="email" aria-label="Teacher email" placeholder="teacher@school.edu" required/>
      <Button disabled={busy}>Add teacher</Button>
    </form>
    {state.teachers.length===0?
      <div className="empty"><h3>No teachers authorized yet</h3><p>Add teacher emails to enable them to review applications.</p></div>
    :
      state.teachers.map(t=>
        <div className="user-row" key={t.email}>
          <div><b>{t.email}</b><p>{t.name}</p></div>
          <Button variant="destructive" disabled={busy} onClick={()=>{
            if(confirm(`Remove ${t.email}?`))
              void run(async()=>{
                if(demo){
                  setState(s=>({...s,teachers:s.teachers.filter(x=>x.email!==t.email)}));
                }else{
                  const result=await api('/api/teacher-management',{action:'remove',email:t.email});
                  if(result.error)throw Error(result.error);
                  setState(await loadState());
                }
              },'Teacher email removed.');
          }}>Remove</Button>
        </div>
      )
    }
  </>
}

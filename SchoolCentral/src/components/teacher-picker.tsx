'use client';
import {useId,useState} from 'react';
import type {ApprovedTeacher} from '@/domain/types';
export function TeacherPicker({teachers}:{teachers:ApprovedTeacher[]}){
 const [query,setQuery]=useState(''),[selected,setSelected]=useState('');
 const statusId=useId();
 const matches=teachers.filter(teacher=>`${teacher.name} ${teacher.email}`.toLowerCase().includes(query.trim().toLowerCase())).sort((a,b)=>a.name.localeCompare(b.name));
 const validSelection=matches.some(teacher=>teacher.email===selected)?selected:'';
 return <fieldset className="teacher-picker"><legend>Approving teacher</legend><label>Search authorized teachers<input type="search" value={query} onChange={event=>{setQuery(event.target.value);setSelected('')}} placeholder="Search by name or school email" aria-describedby={statusId} autoComplete="off"/></label><label>Select your teacher<select name="teacher_email" required value={validSelection} onChange={event=>setSelected(event.target.value)}><option value="">Choose an authorized teacher</option>{matches.map(teacher=><option key={teacher.email} value={teacher.email}>{teacher.name} — {teacher.email}</option>)}</select></label><p id={statusId} role="status" className="form-help">{teachers.length===0?'No authorized teachers are available yet. Ask the Owner to add your teacher.':matches.length===0?'No matching teacher. Try a different name or email, or ask the Owner to add your teacher.':`${matches.length} authorized teacher${matches.length===1?'':'s'} found. Select one above.`}</p></fieldset>
}

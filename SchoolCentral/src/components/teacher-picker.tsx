'use client';
import {useId} from 'react';
import type {ApprovedTeacher} from '@/domain/types';

export function TeacherPicker({teachers}:{teachers:ApprovedTeacher[]}){
 const statusId=useId();
 const sorted=teachers.sort((a,b)=>a.name.localeCompare(b.name));
 
 return <fieldset className="teacher-picker">
  <legend>Approving teacher</legend>
  <label>
   Select an authorized teacher
   <select name="teacher_email" required aria-describedby={statusId}>
    <option value="">Choose an authorized teacher</option>
    {sorted.map(teacher=><option key={teacher.email} value={teacher.email}>{teacher.name} • {teacher.email}</option>)}
   </select>
  </label>
  <p id={statusId} role="status" className="form-help">
   {teachers.length===0
    ?'No authorized teachers are available yet. Ask the Owner to add your teacher.'
    :`${teachers.length} authorized teacher${teachers.length===1?'':'s'} available. Select one above.`
   }
  </p>
 </fieldset>
}

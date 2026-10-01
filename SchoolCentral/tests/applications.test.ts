import {test} from 'node:test';
import assert from 'node:assert/strict';
import {validateApplication} from '../src/domain/applications.ts';
test('accepts a club description and teacher email',()=>assert.doesNotThrow(()=>validateApplication({club_name:'Robotics',description:'Weekly robotics projects and competitions.',teacher_email:'teacher@school.edu'})));
test('requires meaningful club details and a valid email',()=>{const input={club_name:'Robotics',description:'Weekly robotics projects.',teacher_email:'teacher@school.edu'};assert.throws(()=>validateApplication({...input,club_name:' '}));assert.throws(()=>validateApplication({...input,description:'short'}));assert.throws(()=>validateApplication({...input,teacher_email:'invalid'}));assert.throws(()=>validateApplication({...input,description:'x'.repeat(1001)}))});

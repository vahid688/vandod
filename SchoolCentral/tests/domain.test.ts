import {test} from 'node:test';
import assert from 'node:assert/strict';
import {canManage,validateEvent,type Profile} from '../src/domain/types.ts';
const profile=(role:Profile['role'],active=true):Profile=>({id:'u1',name:'Test',email:'test@school.test',role,active});
test('student cannot manage an organization even if stale assignment exists',()=>{assert.equal(canManage(profile('Student'),'org',[{user_id:'u1',organization_id:'org'}]),false)});
test('representative is restricted to assigned organizations',()=>{const assignments=[{user_id:'u1',organization_id:'org'}];assert.equal(canManage(profile('Representative'),'org',assignments),true);assert.equal(canManage(profile('Representative'),'other',assignments),false)});
test('disabled owner has no write access',()=>{assert.equal(canManage(profile('Owner',false),'org',[]),false);assert.equal(canManage(profile('Owner'),'org',[]),true)});
test('rejects invalid times and unsafe external URLs',()=>{const event={title:'Meeting',starts_at:'2026-09-30T12:00:00Z',ends_at:'2026-09-30T13:00:00Z',external_url:''};assert.doesNotThrow(()=>validateEvent(event));assert.throws(()=>validateEvent({...event,ends_at:'2026-09-30T11:00:00Z'}));assert.throws(()=>validateEvent({...event,external_url:'javascript:alert(1)'}));assert.throws(()=>validateEvent({...event,title:' '}));});

import {db} from './supabase';
import type {State} from '../domain/types';
export async function loadState():Promise<State>{if(!db)throw Error('Supabase is not configured.');const tables=['profiles','user_roles','organizations','categories','organization_representatives','events','favorites','settings','representative_applications','approved_teachers'];const results=await Promise.all(tables.map(t=>db!.from(t).select('*')));for(const r of results)if(r.error)throw r.error;const [p,r,o,c,a,e,f,s,applications,teachers]=results.map(r=>r.data!);return {profiles:p.map(p=>({...p,role:r.find(r=>r.user_id===p.id)?.role||'Student'})),organizations:o,categories:c,assignments:a,events:e,favorites:f,applications,teachers,settings:s[0]?{...s[0],school_name:s[0].school_name==='SchoolHub'?'SchoolCentral':s[0].school_name}:{school_name:'SchoolCentral',timezone:'America/Toronto'}};}
export async function write(table:string,value:Record<string,unknown>,remove=false){if(!db)throw Error('Backend unavailable.');const {id,...changes}=value;const q=remove?db.from(table).delete().match(value):table==='profiles'||table==='settings'?db.from(table).update(changes).eq('id',id):db.from(table).upsert(value);const {error}=await q;if(error)throw error;}




import {createClient} from '@supabase/supabase-js';
export const demo=process.env.NEXT_PUBLIC_DEMO_MODE==='true';
const url=process.env.NEXT_PUBLIC_SUPABASE_URL,key=process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
export const db=!demo&&url&&key?createClient(url,key):null;

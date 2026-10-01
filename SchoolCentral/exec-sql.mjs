import fetch from 'node-fetch';

const sql = `
  -- Mark email as confirmed
  UPDATE auth.users
  SET email_confirmed_at = now()
  WHERE email = 'vnnamazi@gmail.com';
  
  -- Promote to Owner
  UPDATE public.user_roles
  SET role = 'Owner'
  WHERE user_id = '71355537-808a-4c70-947b-efbf7872b877'::uuid;
`;

async function executeSQL() {
  // Supabase doesn't expose a direct SQL execute endpoint via REST API
  // We need to use the dashboard or CLI
  
  console.log("SQL to execute:");
  console.log(sql);
  console.log("");
  console.log("For now, please manually execute in Supabase dashboard:");
  console.log("1. Go to SQL Editor");
  console.log("2. Paste the above SQL");
  console.log("3. Click Run");
}

executeSQL();

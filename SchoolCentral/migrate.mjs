import fs from "fs";

async function main() {
  try {
    const sql = fs.readFileSync("supabase/install-fresh.sql", "utf-8");
    console.log(`Read SQL file: ${sql.length} bytes`);
    
    // Execute the SQL via Supabase SQL API
    const response = await fetch("https://tklowdvtasdnkodvxpiy.supabase.co/rest/v1/rpc/pg_execute", {
      method: "POST",
      headers: {
        "Authorization": "Bearer sb_secret_f9cb1nJt3izrkLGmimk16w_oRFaZdvM",
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ sql })
    });
    
    const data = await response.json();
    if (!response.ok) {
      console.error("Error:", data);
      process.exit(1);
    }
    
    console.log("Success! Schema created.");
    process.exit(0);
  } catch (err) {
    console.error("Exception:", err.message);
    process.exit(1);
  }
}

main();

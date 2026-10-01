import fs from "fs";
import https from "https";

const sqlFile = "supabase/install-fresh.sql";
const sql = fs.readFileSync(sqlFile, "utf-8");

console.log(`SQL size: ${sql.length} bytes`);
console.log("Sending SQL to Supabase via HTTPS...");

const data = JSON.stringify({ query: sql });

const options = {
  hostname: "tklowdvtasdnkodvxpiy.supabase.co",
  port: 443,
  path: "/rest/v1/rpc/exec_sql",
  method: "POST",
  headers: {
    "Authorization": "Bearer sb_secret_f9cb1nJt3izrkLGmimk16w_oRFaZdvM",
    "apikey": "sb_publishable_q7MOfZB_D463XUb4N7OSnw_-n90b7F1",
    "Content-Type": "application/json",
    "Content-Length": Buffer.byteLength(data)
  }
};

const req = https.request(options, (res) => {
  let responseBody = "";
  res.on("data", (chunk) => responseBody += chunk);
  res.on("end", () => {
    console.log(`Status: ${res.statusCode}`);
    console.log("Response:", responseBody);
    process.exit(res.statusCode === 200 ? 0 : 1);
  });
});

req.on("error", (err) => {
  console.error("Request error:", err);
  process.exit(1);
});

req.write(data);
req.end();

import type {NextConfig} from 'next';
const config:NextConfig={distDir:process.env.NODE_ENV==='development'?'.next-dev':'.next',async headers(){return [{source:'/sw.js',headers:[{key:'Cache-Control',value:'no-cache, no-store, must-revalidate'},{key:'Content-Type',value:'application/javascript; charset=utf-8'}]},{source:'/teacher-review',headers:[{key:'Referrer-Policy',value:'no-referrer'},{key:'Cache-Control',value:'no-store'}]}]}};
export default config;

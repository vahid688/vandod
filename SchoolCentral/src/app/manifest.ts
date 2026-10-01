import type {MetadataRoute} from 'next';
export default function manifest():MetadataRoute.Manifest{return {name:'SchoolCentral',short_name:'SchoolCentral',description:'Your school life, in one place',start_url:'/',display:'standalone',background_color:'#f5f4ef',theme_color:'#142c40',icons:[{src:'/icon-192.png',sizes:'192x192',type:'image/png',purpose:'any'},{src:'/icon-512.png',sizes:'512x512',type:'image/png',purpose:'maskable'}]}}


import type {Metadata,Viewport} from 'next';
import './globals.css';
export const metadata:Metadata={title:'SchoolCentral — School life, in one place',description:'Your school calendar, clubs, and events.',manifest:'/manifest.webmanifest',icons:{icon:'/icon.svg',apple:'/icon-192.png'}};
export const viewport:Viewport={width:'device-width',initialScale:1,themeColor:'#142c40'};
export default function Layout({children}:{children:React.ReactNode}){return <html lang="en"><body>{children}</body></html>}


export type Role='Student'|'Representative'|'Owner';
export type Profile={id:string;name:string;email:string;role:Role;active:boolean};
export type Organization={id:string;name:string;description:string};
export type Category={id:string;name:string;color:string};
export type Assignment={user_id:string;organization_id:string};
export type RepresentativeApplication={id:string;user_id:string;applicant_name:string;club_name:string;description:string;teacher_email:string;status:'pending_teacher'|'teacher_approved'|'teacher_rejected'|'approved'|'rejected'|'accepted';created_at:string;teacher_reviewed_at:string|null;owner_reviewed_at:string|null;organization_id:string|null};
export type ApprovedTeacher={email:string;name:string};
export type Event={id:string;organization_id:string;category_id:string;title:string;description:string;starts_at:string;ends_at:string;all_day:boolean;location:string;external_url:string;status:'draft'|'published';created_by:string;updated_by:string;created_at:string;updated_at:string};
export type State={profiles:Profile[];organizations:Organization[];categories:Category[];assignments:Assignment[];events:Event[];favorites:{user_id:string;event_id:string}[];applications:RepresentativeApplication[];teachers:ApprovedTeacher[];settings:{school_name:string;timezone:string}};
export function canManage(user:Profile,organizationId:string,assignments:Assignment[]){return user.active&&(user.role==='Owner'||user.role==='Representative'&&assignments.some(a=>a.user_id===user.id&&a.organization_id===organizationId));}
export function validateEvent(event:Pick<Event,'title'|'starts_at'|'ends_at'|'external_url'>){if(!event.title.trim())throw Error('Enter an event title.');if(!Number.isFinite(Date.parse(event.starts_at))||!Number.isFinite(Date.parse(event.ends_at))||Date.parse(event.ends_at)<Date.parse(event.starts_at))throw Error('End time must be after start time.');if(event.external_url&&!/^https?:\/\//i.test(event.external_url))throw Error('External links must start with https:// or http://.');}

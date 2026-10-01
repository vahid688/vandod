export function validateApplication(input:{club_name:string;description:string;teacher_email:string}){
 if(input.club_name.trim().length<2||input.club_name.trim().length>120)throw Error('Club name must contain 2–120 characters.');
 if(input.description.trim().length<10||input.description.trim().length>1000)throw Error('Briefly describe your club in 10–1000 characters.');
 if(!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(input.teacher_email)||input.teacher_email.length>254)throw Error('Enter a valid teacher email.');
}

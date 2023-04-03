//INITDASD JOB CLASS=A,MSGCLASS=H,MSGLEVEL=(1,1),NOTIFY=&SYSUID  
//*                                                              
//* MOD-3: VTOC(0,1,974) INDEX(65,0,50)                          
//* MOD-9: VTOC(0,1,2939) INDEX(196,0,150)                       
//*                                                              
//FORMAT   EXEC PGM=ICKDSF,REGION=0M                             
//SYSPRINT DD SYSOUT=*                                           
//SYSIN DD *                                                     
 INIT UNIT(DE02) NOVALIDATE NVFY VOLID(TEMP01) PURGE -            
   VTOC(0,1,2939) INDEX(196,0,150)                               
/*


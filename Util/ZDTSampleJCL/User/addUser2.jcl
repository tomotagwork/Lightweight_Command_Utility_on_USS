//ADDUSER  JOB   (),                                                
//         CLASS=A,                                                 
//         MSGCLASS=D,                                              
//         MSGLEVEL=(1,1),                                                      
//         TIME=1440                                                
//*                                                                 
//S0       EXEC PGM=IKJEFT01,DYNAMNBR=75,TIME=100,REGION=6M         
//SYSPRINT DD SYSOUT=*                                              
//SYSTSPRT DD SYSOUT=*                                              
//SYSTERM  DD DUMMY                                                 
//SYSUADS  DD DSN=SYS1.UADS,DISP=SHR                                
//SYSLBC   DD DSN=SYS1.BRODCAST,DISP=SHR                            
//SYSTSIN  DD *                                                     
  ADDUSER (@user@) PASSWORD(PSWD) OPERATIONS   -            
   OWNER(SYS1) DFLTGRP(SYS1)                                 -      
   TSO(ACCTNUM(ACCT#) PROC(ISPFPROC) JOBCLASS(A) MSGCLASS(X) -      
      HOLDCLASS(X) SYSOUTCLASS(X) SIZE(4048) MAXSIZE(0)) -          
   OMVS(UID(@uid@) HOME(/u/@homedir@) PROGRAM(/bin/sh))               
  PERMIT ACCT#     ACCESS(READ) CLASS(ACCTNUM) ID(@user@)           
  PERMIT ISPFPROC  ACCESS(READ) CLASS(TSOPROC) ID(@user@)           
  PERMIT JCL       ACCESS(READ) CLASS(TSOAUTH) ID(@user@)           
  PERMIT OPER      ACCESS(READ) CLASS(TSOAUTH) ID(@user@)           
  PERMIT ACCT      ACCESS(READ) CLASS(TSOAUTH) ID(@user@)           
  PERMIT MOUNT     ACCESS(READ) CLASS(TSOAUTH) ID(@user@)           
  PERMIT RECOVER   ACCESS(READ) CLASS(TSOAUTH) ID(@user@)           
  SETROPTS RACLIST(ACCTNUM) REFRESH                                 
  SETROPTS RACLIST(TSOPROC) REFRESH                                 
  SETROPTS RACLIST(TSOAUTH) REFRESH        
  CONNECT @user@ GROUP(IZUADMIN)                          
/*                                                                  
//*---------------------------------------------------------------- 
//ALIAS   EXEC PGM=IDCAMS                                                  
//SYSPRINT DD  SYSOUT=*                                                    
//SYSIN    DD  *                                                           
 DEF   ALIAS(NAME(@user@) REL(USERCAT.Z25B.USER))                              
/*                                                                         
//       

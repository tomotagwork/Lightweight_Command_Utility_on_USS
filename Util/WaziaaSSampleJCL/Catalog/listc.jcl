//LISTC    JOB   MSGCLASS=X,CLASS=A                     
//*-----------------------------------------------------
//*                                                     
//GO       EXEC PGM=IDCAMS,REGION=0M                    
//SYSPRINT DD SYSOUT=*                                  
//SYSIN DD *                                            
 LISTC USERCATALOG ALL                                  
/*                                                      
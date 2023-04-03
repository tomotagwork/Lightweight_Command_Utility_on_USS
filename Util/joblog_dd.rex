/* REXX */

PARSE ARG myJobId myDD

/* say "myJobId:" myJobId  "/ myDD:" myDD */

/*myJobId="JOB05587"*/

rc=isfcalls("on")
     /*************************/
     /* Access the ST display */
     /*************************/
Address SDSF "ISFEXEC ST"
lrc=rc
/* call msgrtn */
if lrc<>0 then
  exit 20
     /****************************/
     /* Loop for all target jobs */
     /****************************/
do ix=1 to JOBID.0
  if JOBID.ix = myJobId then
    do
      /* say JNAME.ix JOBID.ix OWNERID.ix */

      /*****************************************/                               
      /* Issue the ? (JDS) action against the  */                               
      /* row to list the data sets in the job. */                               
      /******************************************/      
      Address SDSF "ISFACT ST TOKEN('"TOKEN.ix"') PARM(NP ?)" ,
         "( prefix jds_" 
      lrc=rc                                                                    
      /* call msgrtn */
      if lrc<>0 then                                                            
        exit 20 

      /**********************************************/                          
      /* Find the JESMSGLG data set and read it     */                          
      /* using ISFBROWSE.  Use isflinelim to limit  */                          
      /* the number of REXX variables returned.     */                          
      /**********************************************/ 
      isflinelim = 0
      do jx=1 to jds_DDNAME.0
        if jds_DDNAME.jx = myDD then 
          do                                                                    
           /*****************************************************/              
           /* Read the records from the data set.               */              
           /*****************************************************/              
             total_lines = 0                                                    
             do until isfnextlinetoken=''                                       
                                                                                
               Address SDSF "ISFBROWSE ST TOKEN('"jds_TOKEN.jx"')"              
                                                                                
               do kx=1 to isfline.0                                             
                  /* Say "Line" total_lines+kx "is:" isfline.kx */
                  Say isfline.kx
               end                                                              
                                                                                
               total_lines = total_lines + isfline.0                            
                  /*****************************/                               
                  /* Set start for next browse */                               
                  /*****************************/                               
               isfstartlinetoken = isfnextlinetoken                             
                                                                                
             end                                                                
                                                                                
             /* Say "  Lines read:" total_lines */
        end 
      end 

    end

end

rc=isfcalls("off")
exit

     /*************************************/                                    
     /* Subroutine to list error messages */                                    
     /*************************************/                                    
msgrtn: procedure expose isfmsg isfmsg2.                                        
     /************************************************/                         
     /* The isfmsg variable contains a short message */                         
     /************************************************/                         
if isfmsg<>"" then                                                              
  Say "isfmsg is:" isfmsg                                                       
     /****************************************************/                     
     /* The isfmsg2 stem contains additional messages    */                     
     /****************************************************/                     
do ix=1 to isfmsg2.0                                                            
  Say "isfmsg2."ix "is:" isfmsg2.ix                                             
end                                                                             
return                       


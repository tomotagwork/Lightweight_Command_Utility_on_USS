/* REXX */

PARSE ARG myJobId

/*myJobId="JOB05587"*/

rc=isfcalls("on")
     /*************************/
     /* Access the ST display */
     /*************************/
Address SDSF "ISFEXEC ST"
lrc=rc
call msgrtn
if lrc<>0 then
  exit 20
     /****************************/
     /* Loop for all target jobs */
     /****************************/
do ix=1 to JOBID.0
  if JOBID.ix = myJobId then
    do
      say JNAME.ix JOBID.ix OWNERID.ix
      isflinelim = 0
      do until isfnextlinetoken=''
        Address SDSF "ISFBROWSE ST TOKEN('"token.ix"')"
        if rc>4 then
          do
            call msgrtn
            exit 20
          end
            /****************************/
            /* Loop through the lines   */
            /****************************/
        do jx=1 to isfline.0
         say isfline.jx
        end
            /*****************************/
            /* Set start for next browse */
            /*****************************/
        isfstartlinetoken = isfnextlinetoken
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


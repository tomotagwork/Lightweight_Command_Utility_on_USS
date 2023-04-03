/* REXX */

PARSE ARG myJobId 

/*myJobId="JOB05587"*/

rc=isfcalls("on")
     /*************************/
     /* Access the ST display */
     /*************************/
Address SDSF "ISFEXEC ST"
lrc=rc
flag=0
/* call msgrtn */
if lrc<>0 then
  exit 20
     /****************************/
     /* Loop for all target jobs */
     /****************************/
do ix=1 to JOBID.0
  if JOBID.ix = myJobId then
    do
      flag=1
      Address SDSF "ISFACT ST TOKEN('"TOKEN.ix"') PARM(NP P)" 
      lrc=rc                                                                    

      say "RC:"||lrc
      if isfmsg<>"" then
        Say isfmsg      

      do ix=1 to isfmsg2.0
        Say isfmsg2.ix
      end

      if lrc<>0 then                                                            
        exit 20 

      leave
    end

end

rc=isfcalls("off")

if flag=0 then 
do
  say myJobId||" does not exist."
  exit 1 
end

exit 0


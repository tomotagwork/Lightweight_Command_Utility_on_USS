/* REXX */
/* Arguments:      */
/*   jobID         */
parse arg myJobID


rc=isfcalls('ON')

Address SDSF "ISFEXEC ST"
lrc=rc
if lrc<>0 then
  exit 20

do ix=1 to JNAME.0

  if JOBID.ix = myJOBID then do 
    line = JNAME.ix||","||JOBID.ix||","||QUEUE.ix||","||RETCODE.ix
    say line
    ix=JNAME.0
  end

end

rc=isfcalls('OFF')
exit


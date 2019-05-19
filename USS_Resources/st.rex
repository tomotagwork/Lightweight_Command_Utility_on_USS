/* REXX */
/* Usage:                 */
/*   st.rex -j=jjj -o=ooo */
/* Arguments:             */
/*   -j=<jobName>         */
/*   -o=<owner>           */
parse arg myJobName myOwner 

myJobName=SUBSTR(myJobName,4)
myOwner=SUBSTR(myOwner,4)


say fixWidth("No.",5)||fixWidth("JOBNAME",10)||fixWidth("JobID",10)||fixWidth("Owner",10)||fixWidth("Prty",5)||fixWidth("Queue",10)||fixWidth("PhaseName",22)||fixWidth("C",3)||fixWidth("Pos",6)||fixWidth("Max-RC",12)||fixWidth("Status",10)||fixWidth("SysName",10)
say "================================================================================================================"

rc=isfcalls('ON')

Address SDSF "ISFEXEC ST"
lrc=rc
if lrc<>0 then
  exit 20

num=1
do ix=1 to JNAME.0

  if (LENGTH(myJobName) = 0 | POS(myJobName, JNAME.ix) > 0) & (LENGTH(myOwner) = 0 | POS(myOwner, OWNERID.ix) > 0) then do 
    line = fixWidth(num,5)||fixWidth(JNAME.ix,10)||fixWidth(JOBID.ix,10)||fixWidth(OWNERID.ix,10)||fixWidth(JPRIO.ix,5)
    line = line||fixWidth(QUEUE.ix,10)||fixWidth(PHASENAME.ix,22)||fixWidth(JCLASS.ix,3)||fixWidth(POS.ix,6)||fixWidth(RETCODE.ix,12)||fixWidth(STATUS.ix,10)
    line = line||fixWidth(SYSNAME.ix,10)
    say line
    num=num+1
  end

end

rc=isfcalls('OFF')
exit


fixWidth:
 word=arg(1)
 width=arg(2)

 if word = "" then do
   word="-"
 end

 if width > LENGTH(word) then do
  result = word||COPIES(' ', width - LENGTH(word))
 end 
 else do
  result = word
 end

 return result

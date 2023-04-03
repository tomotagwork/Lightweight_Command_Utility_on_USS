/* REXX */
/* Usage:                 */
/*   da.rex -j=jjj -o=ooo */
/* Arguments:             */
/*   -j=<jobName>         */
/*   -o=<owner>           */
parse arg myJobName myOwner 

myJobName=SUBSTR(myJobName,4)
myOwner=SUBSTR(myOwner,4)


say "No.  JOBNAME   JOBID     StepName  ProcStep  Type Owner     C  Pos DP  Real  Paging    CPU%  ASID  ASIDX EXCPRT    EXCP      CPU-time  SWAPR     STATUS    SysName"
say "======================================================================================================================================================================"

rc=isfcalls('ON')

Address SDSF "ISFEXEC DA"
lrc=rc
if lrc<>0 then
  exit 20

num=1
do ix=1 to JNAME.0

  if (LENGTH(myJobName) = 0 | POS(myJobName, JNAME.ix) > 0) & (LENGTH(myOwner) = 0 | POS(myOwner, OWNERID.ix) > 0) then do 
    line = fixWidth(num,5)||fixWidth(JNAME.ix,10)||fixWidth(JOBID.ix,10)||fixWidth(STEPN.ix,10)||fixWidth(PROCS.ix,10)||fixWidth(JTYPE.ix,5)
    line = line||fixWidth(OWNERID.ix,10)||fixWidth(JCLASS.ix,3)||fixWidth(POS.ix,4)||fixWidth(DP.ix,4)
    line = line||fixWidth(REAL.ix,6)||fixWidth(PAGING.ix,10)||fixWidth(CPUPR.ix,6)||fixWidth(ASID.ix,6)||fixWidth(ASIDx.ix,6)
    line = line||fixWidth(EXCPRT.ix,10)||fixWidth(EXCP.ix,10)||fixWidth(CPU.ix,10)||fixWidth(SWAPR.ix,10)||fixWidth(STATUS.ix,10)||SYSNAME.ix
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

/* REXX */

PARSE ARG myJobId 

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
      say "-----------------------"
      say "JOBNAME: "||JNAME.ix
      say "JOBID:   "||JOBID.ix
      say "OWNER:   "||OWNERID.ix
      say "-----------------------"

      header = fixWidth("No.",5)||fixWidth("DDNAME",10)||fixWidth("StepName",10)||fixWidth("DSID",5)||fixWidth("Owner",10)||fixWidth("Rec-Cnt",10)||fixWidth("Byte-cnt",10)||fixWidth("CrDate-CrTime",20)
      say header
      say "=============================================================================="

      /*****************************************/                               
      /* Issue the ? (JDS) action against the  */                               
      /* row to list the data sets in the job. */                               
      /******************************************/      
      Address SDSF "ISFACT ST TOKEN('"TOKEN.ix"') PARM(NP ?) (prefix jds_)" 
      lrc=rc                                                                    
      if lrc<>0 then                                                            
        exit 20 

      /**********************************************/                          
      /* Find the JESMSGLG data set and read it     */                          
      /* using ISFBROWSE.  Use isflinelim to limit  */                          
      /* the number of REXX variables returned.     */                          
      /**********************************************/ 
      isflinelim = 500
      do jx=1 to jds_DDNAME.0
        /* say JNAME.ix||"_"||jds_DDNAME.jx JOBID.ix||"."||jds_DSName.jx  */
        line = fixWidth(jx,5)||fixWidth(jds_DDNAME.jx,10)||fixWidth(jds_STEPN.jx,10)||fixWidth(jds_DSID.jx,5)||fixWidth(jds_OWNERID.jx,10)
        line = line||fixWidth(jds_RECCNT.jx,10)||fixWidth(jds_BYTECNT.jx,10)||fixWidth(jds_DSDATE.jx,20)
        say line
      end

      leave
    end

end

rc=isfcalls("off")
exit



/* Functions */
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

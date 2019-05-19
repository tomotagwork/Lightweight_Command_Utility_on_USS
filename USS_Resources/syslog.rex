/* REXX */                                                          
/*--------------------------------------------------------*/
/* Arg1: start date (yyyy/mm/dd)                          */
/* Arg2: start time (hh:mm:ss.nn)                         */
/* Arg3: stop date  (yyyy/mm/dd)                          */
/* Arg4: stop time  (hh:mm:ss.nn)                         */
/*--------------------------------------------------------*/

parse arg start_date start_time stop_date stop_time 

/*
say start_date
say start_time
say stop_date
say stop_time
*/
 
/* getSyslog.rex  mm/dd/yy hh:mm:ss  */
rc=isfcalls('ON') 
if rc <> 0 then do
  err_msg = " ** ISFCALLS ERROR : " rc 
  say err_msg 
  exit 4
end


isfdate="yyyymmdd /"        /* Date format for special variables */ 
isflogstartdate=start_date
isflogstarttime=start_time
isflogstopdate=stop_date
isflogstoptime=stop_time
isflinelim=0

Address SDSF "ISFLOG READ TYPE(SYSLOG)"
/*
do ix=1 to isfmsg2.0
  say isfmsg2.ix
end
*/

do ix=1 to isfline.0     
   say isfline.ix
end

/*
rc = charout(output_file,,)
do ix=1 to isfline.0        /* Process the returned variables */
  /* record = isfline.ix || ESC_R || ESC_N */
  record = isfline.ix || ESC_N
  rc = charout(output_file, record,)
end    
call stream output_file, 'C', 'CLOSE'
*/

rc=isfcalls('OFF')     

exit 0

/* REXX */  

PARSE ARG VAR1

mycmd.0=1
mycmd.1=VAR1

rc=isfcalls('ON')

Address SDSF ISFSLASH "(mycmd.) (WAIT)"

Say "RC: " RC
Say "ISFMSG:  " ISFMSG

if ISFMSG2.0 > 0 then
  do
    do ix=1 to ISFMSG2.0
      SAY "ISFMSG2."ix ":" ISFMSG2.ix
    end
  end

if ISFULOG.0 >0 then
  do
    do ix=1 to ISFULOG.0
      SAY ISFULOG.ix
    end
  end

rc=isfcalls('OFF')


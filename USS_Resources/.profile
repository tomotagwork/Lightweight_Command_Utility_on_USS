set -o vi
PS1="["$LOGNAME@`hostname`:'$PWD'"] "
export TZ=JST-9

UtilDir=/u/cics004/Util
export PATH=$PATH:/usr/lpp/java/J8.0_64/bin:$UtilDir
alias sdsf=sdsf.rex
alias d="sdsf d"
alias f="sdsf f"
alias s="sdsf s"
alias p="sdsf p"
alias v="sdsf v"
alias da="da.sh -p"
alias st="st.sh -p"
alias syslog=syslog.sh
alias jl="joblog.sh"
alias sub="submitJcl.sh -p"


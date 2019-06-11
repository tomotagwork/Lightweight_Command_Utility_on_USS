#!/bin/sh

################################################
# Functions
################################################
checkNumber(){
	# result: 0=false, other=true
	var=$1

	if expr "${var}" : "[0-9]*$" >/dev/null ;then
		result=1
	else
		result=0
	fi

	echo ${result}

}

showSubCommandHelp(){

	echo "-------------------------"
	echo "Select 0 for All DDs or DD Number (with file name optionally), or Input quit"
        echo " subcommand usage"
	echo "   0              :Display Whole JOBLOG"
        echo "   <num>          :Display JOBLOG of selected DD "
        echo "   <num> <file>   :Output selected JOBLOG to file"
        echo "   r              :Refresh DD list"
        echo "   q|quit         :Quit this shell script"
	echo ""

}

getDDList(){
	jobddlist.rex ${JOBID} > ${tempFile}
	cat ${tempFile}
	echo ""

	line_cnt=0
	idx=1
	while read line
	do
		#echo ${line}
		set -A lineArray $(echo ${line})
		if [[ "${lineArray[0]}" = "JOBNAME:" ]] ; then
			JOBNAME=${lineArray[1]}
		fi
		if [[ ${line_cnt} -ge 8 ]] ; then
			#echo ${idx}: ${line}
			arrayDD[${idx}]=${lineArray[1]}
			idx=$((idx+1))
		fi
		line_cnt=$((line_cnt+1))
	done < ${tempFile}
}


################################################
# Main Logic
################################################

tempDir=/tmp
tempKey=Util

if [ $# -lt 1 ]; then
        echo "Usage:"
        echo " $ "$0 "<JOBID>"
        echo " "
        echo " Example1:"
        echo "  $ "$0 "STC03076"
        echo " "
        exit 1
fi


JOBID=$1

pid=$$
thisDateTime=$(date '+%Y%m%d_%H%M%S')
tempFile=${tempDir}/${tempKey}_${pid}_${thisDateTime}.txt

getDDList

#echo "---"
#echo JOBNAME: ${JOBNAME}  / JOBID: ${JOBID}
#echo arrayDD: ${arrayDD[@]} ${#arrayDD[@]}


showSubCommandHelp

while true
do
	read myCommand?"${JOBNAME}/${JOBID} >>> " var1 

	### quit this shell script
	if [[ ${myCommand} = "quit" || ${myCommand} = "q" ]]; then
		echo "bye"
		break

	### Input 0 to output All DDs
	elif [[ ${myCommand} = "0" ]] ; then
		if [[ -z "${var1}" ]]; then
			echo ${JOBID}
			joblog.rex ${JOBID} | more
		else
			if [[ -e ${var1} ]] ; then
				echo File ${var1} exists.  Override?
				read answer?"(y/n) >>>"
				if [[ "${answer}" = "y" ]] ; then
					echo output All Joblog to ${var1}
					joblog.rex ${JOBID} > ${var1}
				else
					echo "*** Canceled ***"
				fi
			else
				echo output All Joblo to ${var1}
				joblog.rex ${JOBID} > ${var1}
			fi
		fi

	### refresh
	elif [[ ${myCommand} = "r" ]]; then
		getDDList

	### Input DD Number
	else
		if [[ $(checkNumber ${myCommand}) -ne 0 ]]; then
			if [[ -z "${var1}" ]]; then
				echo ${arrayDD[${myCommand}]}
				joblog_dd.rex ${JOBID} ${arrayDD[${myCommand}]} | more
			else
				if [[ -e ${var1} ]] ; then
					echo File ${var1} exists.  Override?
					read answer?"(y/n) >>>" 
					if [[ "${answer}" = "y" ]] ; then
						echo output DD ${arrayDD[${myCommand}]} to ${var1}
						joblog_dd.rex ${JOBID} ${arrayDD[${myCommand}]} > ${var1}
					else
						echo "*** Canceled ***"
					fi
				else
					echo output DD ${arrayDD[${myCommand}]} to ${var1}
					joblog_dd.rex ${JOBID} ${arrayDD[${myCommand}]} > ${var1}
				fi
				
			fi
		else
			echo "invalid input: " ${myCommand} ${var1} 
			cat ${tempFile}
			showSubCommandHelp
			
		fi
	fi
done

rm ${tempFile}

exit

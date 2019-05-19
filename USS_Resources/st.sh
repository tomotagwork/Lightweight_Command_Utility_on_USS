#!/bin/bash

scriptName=$(basename $0)
rexxFile=st.rex

######################################
# Function
######################################

showHelp(){
	echo "Usage: ${scriptName} [-j jobname] [-o owner] [-p]"
	echo "  -j: jobname filter (pertial match)"
	echo "  -o: owner filter (partial mathc)"
	echo "  -p: prompt mode"
	exit 0
}

showSubCommandHelp(){
	
	echo "-------------------------"
	echo "Select JOBID Number, or Input quit"
	echo " subcommand usage"
	echo "   <num>     :Display DD list"
	echo "   <num> p   :Purge JOBLOG"
	echo "   r         :Refresh JOBID list"
	echo "   q|quit    :Quit this shell script"
	echo ""

}

checkOption(){
	# result: 0=false, other=true
        var=$1

        if [[ "${var}" = "-" ]]; then
                result=1

        elif [[ $(expr "${var}" : "\-") -ne 0 ]] ; then
                result=1

        else
                result=0
        fi

        echo ${result}

}

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

getJOBIDList(){

	unset arrayJOBID
        ${rexxFile} -j=${arg_j} -o=${arg_o} > ${tempFile}
        cat ${tempFile}
	echo ""

        line_cnt=0
        idx=1
        while read line
        do
                #echo ${line}
                set -A lineArray $(echo ${line})
                if [[ ${line_cnt} -ge 2 ]] ; then
                        #echo ${idx}: ${line}
                        arrayJOBID[${idx}]=${lineArray[2]}
                        idx=$((idx+1))
                fi
                line_cnt=$((line_cnt+1))
        done < ${tempFile}

}

#######################################
# Main Logic
#######################################

tempDir=/tmp
tempKey=Util

pid=$$
thisDateTime=$(date '+%Y%m%d_%H%M%S')
tempFile=${tempDir}/${tempKey}_${pid}_${thisDateTime}.txt

arg_j=
arg_o=
flag_p=0

for option in "$@"
do
	case "$option" in
		'-h')
			showHelp
			exit 0
			;;
		'-j')
			flag_j=1
			if [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				echo "Error: Argument is required for -j"
				showHelp
				exit 0
			fi
			arg_j="$2"
			shift 2
			;;
		'-o')
			flag_o=1
			if [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]]; then
				echo "Error: Argument is required for -o"
				showHelp
				exit 0
			fi
			arg_o="$2"
			shift 2
			;;
		'-p')
			flag_p=1
			shift 1
			;;
		-*)
			echo "Error: Unsupported option: $1"
			showHelp
			exit 0 
			;;
		*)
			if [[ ! -z "$1" ]] && [[ $(checkOption "$1") -eq 0 ]]; then
				shift 1
			fi
			;;
	esac
done

arg_j=$(echo ${arg_j} | tr "a-z" "A-Z")
arg_o=$(echo ${arg_o} | tr "a-z" "A-Z")

#echo arg_j: ${arg_j}
#echo arg_o: ${arg_o}
#echo flag_p: ${flag_p}

#${rexxFile} -j=${arg_j} -o=${arg_o}

### Normal Mode
if [[ ${flag_p} = 0 ]]; then
	${rexxFile} -j=${arg_j} -o=${arg_o}
	exit 0

##Prompt Mode
else
	getJOBIDList
fi

#echo arrayJOBID: ${arrayJOBID[@]} ${#arrayJOBID[@]}
#echo ${tempFile}


showSubCommandHelp

while true
do
	read myCommand?"ST: >> " var1

	### quit this shell script
	if [[ ${myCommand} = "quit" || ${myCommand} = "q" ]]; then
		echo "bye"
		break

	### refresh
	elif [[ ${myCommand} = "r" ]]; then
		getJOBIDList

	### Input JOBID Number
	else
		if [[ $(checkNumber ${myCommand}) -ne 0 ]]; then
			if [[ -z "${var1}" ]]; then
				joblog.sh ${arrayJOBID[${myCommand}]} 
			else
				if [[ "${var1}" = "p" ]]; then
					echo "purge ${arrayJOBID[${myCommand}]}"
					joblog_purge.rex ${arrayJOBID[${myCommand}]}
				else 
					echo "invalid option: ${var1}"
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

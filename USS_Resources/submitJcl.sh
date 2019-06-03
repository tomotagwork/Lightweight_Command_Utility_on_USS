#!/bin/bash

scriptName=$(basename $0)

######################################
# Function
######################################
. commonFunctions.sh

showHelp(){
	echo "Usage: ${scriptName} [-f <jcl_file> | -d <jcl_dataset>] [-i|-s] [-t <timeout>]"
	echo " -f : specify uss file "
	echo " -d : specify PDS member"
	echo " -i : interactive mode to display JOBLOG"
	echo " -s : script mode to execute in shell script"
	echo " -t : timeout in sec for waiting JOB completion "
	echo "       default 0 sec (no timeout) / speciry between 0 to 3600"
	echo " "
	echo "  Example1: ${scriptName} -f sleep.jcl"  
	echo "  Example2: ${scriptName} -d 'CICSSHR.CICS004.JCLLIB(LISTC)'"
	echo ""
	exit 1
}

checkTimeout(){
	# var1: startTime (HH:MM:SS format)
	# var2: timeout value in sec
	# result: 0=false, other=true
	var1=$1
	var2=$2

	result=0

	startHour=$(echo ${var1} | cut -f 1 -d :)
	startMinute=$(echo ${var1} | cut -f 2 -d :)
	startSecond=$(echo ${var1} | cut -f 3 -d :)
	
	startTime=$(expr ${startHour} \* 60 \* 60 + ${startMinute} \* 60 + ${startSecond})
	#echo startTime: ${startTime}

	thisTime=$(date '+%H:%M:%S')
	thisHour=$(echo ${thisTime} | cut -f 1 -d :)
	thisMinute=$(echo ${thisTime} | cut -f 2 -d :)
	thisSecond=$(echo ${thisTime} | cut -f 3 -d :)

	#echo ${thisHour} ${thisMinute} ${thisSecond}
	thisTime=$(expr ${thisHour} \* 60 \* 60 + ${thisMinute} \* 60 + ${thisSecond})
	if [[ ${thisTime} -lt ${startTime} ]]; then
		thisTime=$(expr ${thisTime} + 86400)
	fi
	#echo thisTime: ${thisTime}

	expireTime=$(expr ${startTime} + ${var2})

	if [[ ${thisTime} -ge ${expireTime} ]]; then
		result=1
	fi

	echo ${result}	

}


#######################################
# Main Logic
#######################################

arg_f=
flag_f=0
arg_d=
flag_d=0
flag_i=0
flag_s=0
arg_t=0
flag_t=0

for option in "$@"
do
	case "$option" in
		'-h')
			showHelp
			exit 0
			;;
                '-f')
                        flag_f=1
			if [[ ${flag_d} != 0 ]] ; then
				echo "Error: Can not specify both -f and -d option."
				showHelp
				exit 1
			fi

                        if [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
                                echo "Error: Argument is required for -f"
                                showHelp
                                exit 0
                        fi
                        arg_f="$2"
                        shift 2
                        ;;
                '-d')
                        flag_d=1
			if [[ ${flag_f} != 0 ]] ; then
				echo "Error: Can not specify both -f and -d option."
				showHelp
				exit 1
			fi

			if [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]]; then
				echo "Error: Argument is required for -d"
				showHelp
				exit 0
			fi
			arg_d="$2"
			shift 2
			;;
		'-i')
			flag_i=1
			if [[ ${flag_s} != 0 ]] ; then
				echo "Error: Can not specify both -i and -s option."
				showHelp
				exit 1
			fi
			shift 1
			;;
		'-s')
			flag_s=1
			if [[ ${flag_i} != 0 ]] ; then
				echo "Error: Can not specify both -i and -s option."
				showHelp
				exit 1
			fi
			shift 1
			;;
		'-t')
			flag_t=1
			if [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				echo "Error: Argument is required for -t"
				showHelp
				exit 1
			elif [[ $(checkNumber "$2") -eq 0 ]] ; then
				echo "Error: Argument of -t must be number"
				showHelp
				exit 1
			elif [[ $2 -ge 3600 ]] ; then
				echo "Error: set 0-3600 sec in -t option"
				showHelp
				exit 1
			else
				arg_t=$2
				shift 2
			fi
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

#echo arg_f: ${arg_f}
#echo flag_f: ${flag_f}
#echo arg_d: ${arg_d}
#echo flag_d: ${flag_d}
#echo flag_i: ${flag_i}
#echo flag_s: ${flag_s}
#echo arg_t: ${arg_t}
#echo flag_t: ${flag_t}


if [[ ${flag_f} != 0 ]]; then
	jclName=${arg_f}
	
elif [[ ${flag_d} != 0 ]]; then
	jclName="//'${arg_d}'"

else
	echo "Invalid option"
	showHelp
	exit 0

fi


JobID=$(submit -j ${jclName})
rc=$?

if [[ ${rc} -eq 0 && "${JobID}" != "" ]]; then
	echo "JobID:" ${JobID}
else
	exit 1
fi


### Normal Mode (without waiting completion)
if [[ ${flag_i} -eq 0  &&  ${flag_s} -eq 0 ]]; then
	exit 0
fi


### Interactive Mode or Script Mode (waiting completion and display JOBLOG)

startTime=$(date '+%H:%M:%S')

printf "waiting"

isTimedOut=0
while true
do
	result=$(checkJobStatus.rex ${JobID})

	IFS=","
	set -- ${result}
	JobName=$1
	Queue=$3
	Retcode=$4
	#echo debug: ${JobName} ${Queue} ${Retcode}

	if [[ ${Queue} = "" ]] || [[ ${Queue} = "EXECUTION" ]] ; then
		if [[ ${arg_t} -gt 0 ]]; then 
			if [[ $(checkTimeout ${startTime} ${arg_t}) -ne 0 ]]; then
				echo ""
				echo "Timed Out!"
				isTimeOut=1
				break
			fi
		fi
		printf "."
		sleep 1
	else
		echo ""
		echo Max-RC: ${Retcode}
		break
	fi
done

if [[ ${flag_i} -ne 0 ]]; then
	joblog.sh ${JobID}
fi

IFS=" "
set -A arrayRetcode $(echo ${Retcode})
if [[ ${flag_s} -ne 0 ]]; then
	echo ${Retcode}
	if [[ isTimeOut -ne 0 ]]; then
		exit 200

	elif [[ $(checkNumber ${arrayRetcode[1]}) -ne 0 ]]; then
		if [[ ${arrayRetcode[1]} -le 255 ]]; then
			exit ${arrayRetcode[1]}
		else
			exit 255
		fi

	else
		exit 255
	fi
fi
		

exit

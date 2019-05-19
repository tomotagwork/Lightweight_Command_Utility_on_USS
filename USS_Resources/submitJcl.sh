#!/bin/bash

scriptName=$(basename $0)

######################################
# Function
######################################

showHelp(){
	echo "Usage: ${scriptName} [-f <jcl_file> | -d <jcl_dataset>] [-p]"
	echo " -f : specify uss file "
	echo " -d : specify PDS member"
	echo " -p : prompt mode to display JOBLOG"
	echo " "
	echo "  Example1: ${scriptName} -f sleep.jcl"  
	echo "  Example2: ${scriptName} -d 'CICSSHR.CICS004.JCLLIB(LISTC)'"
	echo ""
	exit 1
}

checkOption(){
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


#######################################
# Main Logic
#######################################

arg_f=
flag_f=0
arg_d=
flag_d=0
flag_p=0

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
if [[ ${flag_p} = 0 ]] ; then
	exit 0
fi


### Prompt Mode (waiting completion and display JOBLOG)

printf "waiting"
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
		printf "."
		sleep 1
	else
		echo ""
		echo Max-RC: ${Retcode}
		break
	fi
done

joblog.sh ${JobID}

exit

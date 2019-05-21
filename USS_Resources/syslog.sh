#!/bin/bash

scriptName=$(basename $0)
rexxFile=syslog.rex

######################################
# Function
######################################

showHelp(){
	echo "Usage: ${scriptName}  [-h] | [-w [n] ] [-l [n] ] | [-fd YYYY/MM/DD] [-ft hh:mm:ss] [-td YYYY/MM/DD] [-tt hh:mm:ss] "
	echo "  -h:              Show this help"
	echo "  -w [n]:          Watch(tail) syslog with specifed interval in second. n=1-300 (default: 2sec)"
	echo "  -l [n]:          Display syslog of last <n> minutes. n=1-59 (default: 1min)"
	echo "  -fd YYYY/MM/DD   From Date (default: today)"
	echo "  -ft hh:mm:ss     From Time (default: 00:00:00)"
	echo "  -td YYYY/MM/DD   To Date (default: today)"
	echo "  -tt hh:mm:ss     To Time (default: now)"
	echo "  without option   Display syslog of last 1 minute."
	echo ""
	exit 0
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

checkDate(){
	# result: 0=false, other=true
	var=$1

	if [[ $(expr "${var}" : "[0-9][0-9][0-9][0-9]/[0-1][0-9]/[0-3][0-9]") -ne 0 ]] ; then
		result=1
	else
		result=0
	fi

	echo ${result}

}

checkTime(){
	# result: 0=false, other=true
	var=$1

	if [[ $(expr "${var}" : "[0-2][0-9]:[0-5][0-9]:[0-5][0-9]") -ne 0 ]] ; then
		result=1
	else
		result=0
	fi

	echo ${result}
}

getRelativeTime(){
	var=$1

	if [[ ${thisMinute} -ge ${var} ]] ; then
		min=$(expr ${thisMinute} - ${var})
		if [[ ${min} -lt 10 ]] ; then
			min=0${min}
		fi
		result=${thisHour}:${min}:${thisSecond}
	else
		if [[ ${thisHour} -eq 0 ]] ; then
			result=00:00:00
		else
			hour=$(expr ${thisHour} - 1)
			if [[ ${hour} -lt 10 ]]; then
				hour=0${hour}
			fi

			min=$(expr 60 + ${thisMinute} - ${var})
			if [[ ${min} -lt 10 ]] ; then
				min=0${min}
			fi

			result=${hour}:${min}:${thisSecond}
		fi

	fi	

	echo ${result}

}


#######################################
# Main Logic
#######################################


set -A arrayDateTime $(date '+%Y %m %d %H %M %S')
thisYear=${arrayDateTime[0]}
thisMonth=${arrayDateTime[1]}
thisDay=${arrayDateTime[2]}
thisHour=${arrayDateTime[3]}
thisMinute=${arrayDateTime[4]}
thisSecond=${arrayDateTime[5]}


#echo ${thisHour}:${thisMinute}:${thisSecond}

#fromRelativeTime=$(getRelativeTime 1)
#echo ${fromRelativeTime}


arg_w=2
arg_l=1
arg_fd=
arg_ft=
arg_td=
arg_tt=
flag_w=0
flag_l=0
flag_fd=0
flag_ft=0
flag_td=0
flag_tt=0


for option in "$@"
do
	case "$option" in
		'-h')
			showHelp
			exit 0
			;;
		'-w')
			flag_w=1
			if [[ ${flag_fd} -eq 1 ]] || [[ ${flag_ft} -eq 1 ]] || [[ ${flag_td} -eq 1 ]] || [[ ${flag_tt} -eq 1 ]] ; then
				echo "Error: -w option can not be specified with -fd, -ft, -td, -tt."
				showHelp
				exit 0
			elif [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				# use arg_w default value
				shift 1
			elif [[ $(checkNumber "$2") -eq 0 ]] ; then
				echo "Error: Argument of -w must be number"
				showHelp
				exit 0
			elif [[ $2 -gt 300 ]] ; then
				echo "Error: set 1-300 sec in -w option"
				showHelp
				exit 0
			else
				arg_w=$2
				shift 2
			fi
			;;
		'-l')
			flag_l=1
			if [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				# use arg_l default value
				shift 1
			elif [[ $(checkNumber "$2") -eq 0 ]] ; then
				echo "Error: Argument of -l must be number"
				showHelp
				exit 0
			elif [[ $2 -ge 60 ]] ; then
				echo "Error: set 1-59 min in -l option"
				showHelp
				exit 0
			else
				arg_l=$2
				shift 2
			fi
			;;
		'-fd')
			flag_fd=1	
			if [[ ${flag_w} -eq 1 ]]; then
				echo "Error: -w option can not be specified with -fd, -ft, -td, -tt."
				showHelp
				exit 0
			elif [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				echo "Error: Argument is required for -fd"
				showHelp
				exit 0
			elif [[ $(checkDate "$2") -eq 0 ]] ; then
				echo "Error: Invalid format. Set YYYY/MM/DD format in -fd option"
				showHelp
				exit 0
			else
				arg_fd=$2
                        	shift 2
			fi
			;;
		'-ft')
			flag_ft=1
			if [[ ${flag_w} -eq 1 ]]; then
				echo "Error: -w option can not be specified with -fd, -ft, -td, -tt."
				showHelp
				exit 0
			elif [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				echo "Error: Argument is required for -ft"
				showHelp
				exit 0
			elif [[ $(checkTime "$2") -eq 0 ]] ; then
				echo "Error: Invalid format. Set hh:mm:ss format in -ft option"
				showHelp
				exit 0
			else
				arg_ft=$2
				shift 2
			fi
			;;
		'-td')
			flag_td=1
			if [[ ${flag_w} -eq 1 ]]; then
				echo "Error: -w option can not be specified with -fd, -ft, -td, -tt."
				showHelp			
				exit 0			
			elif [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				echo "Error: Argument is required for -td"
				showHelp
				exit 0
			elif [[ $(checkDate "$2") -eq 0 ]] ; then
				echo "Error: Invalid format. Set YYYY/MM/DD format in -td option"
				showHelp
				exit 0
			else
				arg_td=$2
				shift 2
			fi
			;;
		'-tt')
			flag_tt=1
			if [[ ${flag_w} -eq 1 ]]; then
				echo "Error: -w option can not be specified with -fd, -ft, -td, -tt."
				showHelp
				exit0
			elif [[ -z "$2" ]] || [[ $(checkOption "$2") -ne 0 ]] ; then
				echo "Error: Argument is required for -tt"
				showHelp
				exit 0
			elif [[ $(checkTime "$2") -eq 0 ]] ; then
				echo "Error: Invalid format. Set hh:mm:ss format in -tt option"
				showHelp
				exit 0
			else
				arg_tt=$2
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


#echo arg_w: ${arg_w}
#echo arg_l: ${arg_l}
#echo arg_fd: ${arg_fd}
#echo arg_ft: ${arg_ft}
#echo arg_td: ${arg_td}
#echo arg_tt: ${arg_tt}


###### Show Last <n> min syslog
if [[ ${flag_l} -eq 1 ]] ; then
	fromDate=${thisYear}/${thisMonth}/${thisDay}
	fromTime=$(getRelativeTime ${arg_l})
	toDate=${thisYear}/${thisMonth}/${thisDay}
	toTime=${thisHour}:${thisMinute}:${thisSecond}

	echo ${fromDate} ${fromTime} -  ${toDate} ${toTime}
	${rexxFile} ${fromDate} ${fromTime}.01 ${toDate} ${toTime}.00

##### Show specific period
elif [[ ${flag_fd} -eq 1 ]] || [[ ${flag_ft} -eq 1 ]] || [[ ${flag_td} -eq 1 ]] || [[ ${flag_tt} -eq 1 ]] ; then
	if [[ ${flag_fd} -eq 1 ]]; then
		fromDate=${arg_fd}
	else
		fromDate=${thisYear}/${thisMonth}/${thisDay}
	fi

	if [[ ${flag_ft} -eq 1 ]]; then
		fromTime=${arg_ft}
	else
		fromTime=00:00:00
	fi

	if [[ ${flag_td} -eq 1 ]]; then	
		toDate=${arg_td}
	else
		toDate=${thisYear}/${thisMonth}/${thisDay}
	fi

	if [[ ${flag_tt} -eq 1 ]]; then
		toTime=${arg_tt}
	else
		toTime=${thisHour}:${thisMinute}:${thisSecond}
	fi

	echo ${fromDate} ${fromTime} - ${toDate} ${toTime}
	${rexxFile} ${fromDate} ${fromTime}.01 ${toDate} ${toTime}.00
	exit 0

##### Show Last 1 min syslog (default)
else
	fromDate=${thisYear}/${thisMonth}/${thisDay}
	fromTime=$(getRelativeTime ${arg_l})
	toDate=${thisYear}/${thisMonth}/${thisDay}
	toTime=${thisHour}:${thisMinute}:${thisSecond}

	echo ${fromDate} ${fromTime} -  ${toDate} ${toTime}
	${rexxFile} ${fromDate} ${fromTime}.01 ${toDate} ${toTime}.00	

fi

if [[ ${flag_w} -eq 1 ]]; then
	fromDate=${toDate}
	fromTime=${toTime}

	sleep 1
	
	while true
	do
		toDate=$(date '+%Y/%m/%d')
		toTime=$(date '+%T')
		
		${rexxFile} ${fromDate} ${fromTime}.01 ${toDate} ${toTime}.00

		sleep ${arg_w}

		fromDate=${toDate}
		fromTime=${toTime}

	done
	
fi


exit


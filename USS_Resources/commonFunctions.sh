#!/bin/bash

######################################
# Functions
######################################

### check whether string is "option" (stats with "-")
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




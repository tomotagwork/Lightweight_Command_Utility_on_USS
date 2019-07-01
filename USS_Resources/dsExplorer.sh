#!/bin/sh

################################################
# Functions
################################################

showSubCommandHelp(){

	echo "-------------------------"
	echo "subcommand usage"
	echo "   pwd                     :Print current working directory"
	echo "   cd <dir>                :Change working directory"
	echo "                             you can specify absolute/relative path with using \"..\""
	echo "   ls                      :List dataset for current working directory"
	echo "   lm                      :List member for current working directory (valid only at PDS dataset)"
	echo "   ld                      :List detail of dataset for current working directory by using ftp"
	echo "                             this command requires ftp password at first time "
	echo "   vi <member>             :Edit/Create member in current working directory by using vi"
	echo "   rm <member>             :Remove member in current working directory"
	echo "   cp <mem1> <mem2>        :Copy member from <mem1> to <mem2> in current working directory"
	echo "   clear                   :Clear cached ftp password"
	echo "   q|quit                  :Quit this shell script"
	echo ""

}

checkDS(){
	# result: 0=false, other=true
	dsName=$1

	result=0
	unset data
	export TSOPROFILE="noprefix"
	data=$(tsocmd "listcat level ('${dsName}') " 2>/dev/null | grep -v  -E "IN-CAT ---|LISTING FROM CATALOG --" | sed -e s/"-"//g | sed -e s/"**"//g)

	if [[ $(expr "${data}" : "IDC3012I") -ne 0 && $(expr "${data}" : ".*NOT FOUND") -ne 0 ]]; then
		result=0
	else
		result=1
	fi

	echo ${result}

}


getHLQList(){
	export TSOPROFILE="noprefix"
	data=$(tsocmd "listcat usercatalog all" 2>/dev/null | grep -E "USERCATALOG ---|ALIAS----" |  sed -e s/"USERCATALOG ---"//g -e s/"ALIAS----"//g | sed s/"\..*$"//g | sort -u )

	idx=0
	while read line
	do
		arrayHLQ[${idx}]=${line}
		idx=$((idx+1))
	done <<-END
	${data}
	END

	#echo ${#arrayHLQ[@]} / ${arrayHLQ[@]}
}

displayHLQList(){
	for item in ${arrayHLQ[@]}
	do
		echo ${item}
	done

}

getDSList(){
	dsName=$1

	unset data
	export TSOPROFILE="noprefix"
	data=$(tsocmd "listcat level ('${dsName}') " 2>/dev/null | grep -v  -E "IN-CAT ---|LISTING FROM CATALOG --" | sed -e s/"-"//g | sed -e s/"**"//g)
	#echo ---
	#echo ${data}
	#echo ---

	unset arrayDSName
	unset arrayDSType

	if [[ $(expr "${data}" : "IDC3012I") -ne 0 && $(expr "${data}" : ".*NOT FOUND") -ne 0 ]]; then
		return 0

	else
		idx=0
		while read dstype dsname
		do
			arrayDSName[${idx}]=${dsname}
			arrayDSType[${idx}]=${dstype}
			#echo ${dsname}/${dstype}
			idx=$((idx+1))
		done <<-END
		${data}
		END
	fi

	#echo ${#arrayDSName[@]} / ${arrayDSName[@]}

}

displayDSList(){
	idx=0
	for item in ${arrayDSName[@]}
	do
		#echo ${idx}: ${arrayDSType[${idx}]} ${item}
		#printf "%-6d %-10s %-40s " ${idx} ${arrayDSType[${idx}]} ${item}

		printf "%-6d %-10s %-40s \n" ${idx} ${arrayDSType[${idx}]} ${item}

		idx=$((idx+1))
	done

}

displayPDSMemberList(){
	dsName=$1
	result=$(tsocmd "listds ('${dsName}') MEMBERS" 2> /dev/null)
	rc=$?

	if [[ ${rc} -gt 0 ]] ; then
		echo "Error: CWD is not PDS dataset!"
	else
		idx=0
		while read line
		do
			if [[ ${idx} -lt 2 ]]; then
				# do nothing
			elif [[ ${idx} -eq 2 ]]; then
				if expr "${line}" : ".*PO" > /dev/null ; then
					# do nothing / it's PDS
				else
					# break this loop because it's not PDS
					echo "Error2: CWD is not PDS dataset!"
					break
				fi
			else
				echo ${line}
			fi
			idx=$((idx+1))
		done <<-END
		${result}
		END
	fi

}

checkPDS(){
	# result: 0=false, other=true
	dsName=$1
	result=0

	temp=$(tsocmd "listds ('${dsName}') MEMBERS" 2> /dev/null)
	rc=$?

	if [[ ${rc} -gt 0 ]] ; then
		result=0
	else
		idx=0
		while read line
		do
			if [[ ${idx} -lt 2 ]]; then
				# do nothing
			elif [[ ${idx} -eq 2 ]]; then
				if expr "${line}" : ".*PO" > /dev/null ; then
					#it's PDS
					result=1
					break
				else
					#it's not PDS
					result=0
					break
				fi
			else
				#unexpected
				break
			fi
			idx=$((idx+1))
		done <<-END
		${temp}
		END
	fi

	echo ${result}

}

createFTPCommand(){
	dataset=$1

	echo ${LOGNAME}
	echo ${ftpPassword}
	echo "cd //${dataset}"
	echo dir
	echo quit

}

displayDSDetail(){
	dataset=$1

	if [[ "${ftpPassword}" = "" ]]; then
		read ftpPassword?" Input Password for $LOGNAME : "
	fi

	unset ftpResult
	ftpResult=$(createFTPCommand ${dataset} | ftp $(hostname) | tail -n +20 | sed -e '/^Command/d' -e '/^>>> QUIT/d' -e '/Quit command/d')
	rc=$?

	if [[ ${rc} -ne 0 ]]; then
		echo "Error: ftp failed!"
	else
		cat <<-END
		${ftpResult}
		END
	fi

}

getTargetDir(){
	tempCwd=$1
	path=$2

	set -A tempCwdArray $(echo ${tempCwd} | tr -s "/" " ")
	#echo tempCwdArray: ${tempCwdArray[@]} ${#tempCwdArray[@]} >> test.log

	set -A pathArray $(echo ${path} | tr -s "/" " ")
	#echo pathArray: ${pathArray[@]} ${#pathArray[@]} >> test.log

	if [[ ${path} = "/" ]] ; then
		newCwd=${path}

	elif [[ $(expr "${path}" : "\/") -ne 0 ]] ; then
		##### Absolute Path
		newCwd=${path}

	else
		##### Relative Path
		idx_cwd=${#tempCwdArray[@]}
		idx=0
		pathArrayLength=${#pathArray[@]}
		while [[ ${idx} -lt ${pathArrayLength} ]]
		do
			dir=${pathArray[idx]}
			#echo ${dir} >> test.log

			if [[ "${dir}" = "." ]]; then
				# do nothing

			elif [[ "${dir}" = ".." ]]; then
				if [[ "${idx_cwd}" -le 0 ]]; then
					echo "Error: Invalid Path" 
					return 1
				else
					idx_cwd=$((idx_cwd-1))
					unset tempCwdArray[${idx_cwd}]
				fi

			else
				tempCwdArray[${idx_cwd}]=${dir}
				idx_cwd=$((idx_cwd+1))
			fi

			idx=$((idx+1))
		done

		tempCwdArrayLength=${#tempCwdArray[@]}
		#echo tempCwdArrayLength: ${tempCwdArray[@]} ${tempCwdArrayLength} >> test.log
		idx=0
		newCwd="/"
		while [[ ${idx} -lt ${tempCwdArrayLength} ]]
		do
			#echo ${idx} >> test.log
			newCwd=${newCwd}${tempCwdArray[${idx}]}/
			idx=$((idx+1))
		done

	fi

	## get new DSname from newCwd and check wheteher new DSname exists
	if [[ "${newCwd}" = "/" ]]; then
		result="/"

	else
		newDSname=$(echo ${newCwd} | sed -e "s/^\///" -e "s/\/$//" | sed -e "s/\//./g" | tr "a-z" "A-Z")
		#echo newDSname: ${newDSname} >> test.log
		if [[ $(checkDS ${newDSname}) -ne 0 ]]; then
			result=${newCwd}
		else
			#echo "----debug : Invalid Dataset: ${newDSname}" >> test.log 
			echo "Invalid Dataset: ${newDSname}"
			exit 1
		fi
	fi
		
	echo ${result}
	
}




################################################
# Main Logic
################################################

tempDir=/tmp
tempKey=Util
pid=$$


#test=$1
#temp=$(checkPDS ${test})
#displayDSDetail ${test}
#echo temp: ${temp}
#exit


showSubCommandHelp
cwd="/"

while true
do
	read myCommand?"${cwd} >>> " var1 var2 

	if [[ "${myCommand}" = "quit" || ${myCommand} = "q" ]]; then
		echo "bye"
		break

	elif [[ "${myCommand}" = "pwd" ]] ; then
		#echo ${cwd}
		echo ${cwd} | sed -e "s/^\///" -e "s/\/$//" | sed -e "s/\//./g" | tr "a-z" "A-Z"

	elif [[ "${myCommand}" = "cd" ]] ; then
		result=$(getTargetDir ${cwd} ${var1})
		rc=$?
		if [[ ${rc} = 0 ]] ; then
			cwd=${result}
		else
			echo ${result}
		fi

	elif [[ "${myCommand}" = "ls" ]]; then
		if [[ "${cwd}" = "/" ]]; then
			getHLQList
			if [[ "${var1}" = "|" && ! -z "${var2}" ]]; then
				displayHLQList | ${var2}
			else
				displayHLQList 
			fi
		else 
			dsName=$(echo ${cwd} | sed -e "s/^\///" -e "s/\/$//" | sed -e "s/\//./g" | tr "a-z" "A-Z")
			getDSList ${dsName}
			#echo var1: ${var1}  var2: ${var2}
			if [[ "${var1}" = "|" && ! -z "${var2}" ]]; then
				displayDSList | ${var2}
			else
				displayDSList
			fi
		fi
	elif [[ "${myCommand}" = "lm" ]]; then
		if [[ "${cwd}" = "/" ]]; then
			echo "Invalid command. current working directory is not PDS dataset" 
		else
			dsName=$(echo ${cwd} | sed -e "s/^\///" -e "s/\/$//" | sed -e "s/\//./g" | tr "a-z" "A-Z")
			if [[ "${var1}" = "|" && ! -z "${var2}" ]]; then
				displayPDSMemberList ${dsName} | ${var2}
			else
				displayPDSMemberList ${dsName}
			fi
		fi
	elif [[ "${myCommand}" = "ld" ]]; then
		if [[ "${cwd}" = "/" ]]; then
			echo "This command is invalid at root directory."
		else
			dsName=$(echo ${cwd} | sed -e "s/^\///" -e "s/\/$//" | sed -e "s/\//./g" | tr "a-z" "A-Z")
			if [[ "${var1}" = "|" && ! -z "${var2}" ]]; then
				displayDSDetail ${dsName} | ${var2}
			else
				displayDSDetail ${dsName}
			fi
		fi
	elif [[ "${myCommand}" = "vi" ]]; then
		if [[ "${cwd}" = "/" ]]; then
			echo "This command is invalid at root directory."
		elif [[ -z "${var1}" ]] ; then
			echo "Error: set argument"		
		else
			dsName=$(echo ${cwd} | sed -e "s/^\///" -e "s/\/$//" | sed -e "s/\//./g" | tr "a-z" "A-Z")
			if [[ $(checkPDS ${dsName}) -eq 0 ]]; then
				echo "Error: Invalisd command. current working directory is not PDS dataset"
			else
				echo ---OK---
				memberName=$(echo ${var1} | tr "a-z" "A-Z")
				if [[ ${#memberName} -gt 8 ]]; then
					echo "Error: Invalid member name ${memberName}. It's over 8 characters."
					continue
				fi
				
				thisDateTime=$(date '+%Y%m%d_%H%M%S')
				tempFile=${tempDir}/${tempKey}_${pid}_${thisDateTime}_${memberName}.txt
				cp "//'${dsName}(${memberName})'" ${tempFile}
				rc=$?
				if [[ ${rc} -ne 0 ]]; then
					flagNewfile=1
				else
					flagNewfile=0
				fi

				########## Invoke vi #########
				vi ${tempFile}

				if [[ -e ${tempFile} ]]; then

					if [[ ${flagNewfile} -ne 0 ]]; then
						cp ${tempFile} "//'${dsName}(${memberName})'"
						rc=$?
						if [[ ${rc} -ne 0 ]]; then
							echo "Error: copy failed"
						else
							echo "Created new member ${dsName}(${memberName})"
						fi
					else 
						echo "Override member? / ${dsName}(${memberName})"
						read answer?"(y/n) >>>"
						if [[ "${answer}" = "y" ]] ; then
							echo "save this change"
							cp ${tempFile} "//'${dsName}(${memberName})'"
							rc=$?
							if [[ ${rc} -ne 0 ]]; then
								echo "Error: copy failed"
							else
								echo "Created new member ${dsName}(${memberName})"
							fi
						else
							echo "change is discarded"
						fi
					fi
					rm ${tempFile}
				fi
					
			fi
		fi
	elif [[ "${myCommand}" = "rm" ]]; then
		if [[ "${cwd}" = "/" ]]; then
			echo "This command is invalid at root directory."
		elif [[ -z "${var1}" ]] ; then
			echo "Error: set argument"
		else
			dsName=$(echo ${cwd} | sed -e "s/^\///" -e "s/\/$//" | sed -e "s/\//./g" | tr "a-z" "A-Z")
			if [[ $(checkPDS ${dsName}) -eq 0 ]]; then
				echo "Error: Invalisd command. current working directory is not PDS dataset"
			else
				memberName=$(echo ${var1} | tr "a-z" "A-Z")
				if [[ ${#memberName} -gt 8 ]]; then
					echo "Error: Invalid member name ${memberName}. It's over 8 characters."
					continue
				fi

				thisDateTime=$(date '+%Y%m%d_%H%M%S')
				tempFile=${tempDir}/${tempKey}_${pid}_${thisDateTime}_${memberName}.txt
				cp "//'${dsName}(${memberName})'" ${tempFile}
				rc=$?
				if [[ ${rc} -ne 0 ]]; then
					echo "Error: ${dsName}(${memberName}) does not exist or other reason."
					continue
				else
					echo "Remove member? / ${dsName}(${memberName})"
					read answer?"(y/n) >>>"
					if [[ "${answer}" = "y" ]] ; then
						echo "remove this member"
						mv "//'${dsName}(${memberName})'" ${tempFile}
					else
						echo "canceled"
					fi
					
					if [[ -e ${tempFile} ]]; then
						rm ${tempFile}
					fi
				fi
			fi		

		fi

	elif [[ "${myCommand}" = "cp" ]]; then
		if [[ "${cwd}" = "/" ]]; then
			echo "This command is invalid at root directory."
		elif [[ -z "${var1}" ]] || [[ -z "${var2}" ]] ; then
			echo "Error: set 2 arguments"
		else
			dsName=$(echo ${cwd} | sed -e "s/^\///" -e "s/\/$//" | sed -e "s/\//./g" | tr "a-z" "A-Z")
			if [[ $(checkPDS ${dsName}) -eq 0 ]]; then
				echo "Error: Invalisd command. current working directory is not PDS dataset"
			else
				memberName1=$(echo ${var1} | tr "a-z" "A-Z")
				if [[ ${#memberName1} -gt 8 ]]; then
					echo "Error: Invalid member name1 ${memberName1}. It's over 8 characters."
					continue
				fi

				memberName2=$(echo ${var2} | tr "a-z" "A-Z")
				if [[ ${#memberName2} -gt 8 ]]; then
					echo "Error: Invalid member name2 ${memberName2}. It's over 8 characters."
					continue
				fi

				### check source member
				cp "//'${dsName}(${memberName1})'" /dev/null > /dev/null 2>&1
				rc=$?
				if [[ ${rc} -ne 0 ]]; then
					echo "Error: Source member ${dsName}(${memberName1}) does not exist."
					continue
				fi

				### check target member
				cp "//'${dsName}(${memberName2})'" /dev/null > /dev/null 2>&1
				rc=$?

				if [[ ${rc} -eq 0 ]]; then
					echo "Target member ${dsName}(${memberName2}) exists. Override?"
					read answer?"(y/n) >>>"
					if [[ "${answer}" = "y" ]] ; then
						echo "copy from ${dsName}(${memberName1}) to ${dsName}(${memberName2})"
						cp "//'${dsName}(${memberName1})'" "//'${dsName}(${memberName2})'"
					else
						echo "canceled"
					fi
				else
					echo "copy from ${dsName}(${memberName1}) to ${dsName}(${memberName2})"
					cp "//'${dsName}(${memberName1})'" "//'${dsName}(${memberName2})'"
				fi
			fi

		fi

	elif [[ "${myCommand}" = "clear" ]]; then 
		echo "Clear cached ftp passwrd"
		unset ftpPassword

	else
		echo "Invalid command:  ${myCommand} ${var1} ${var2}"
		showSubCommandHelp
	fi
done

exit

	

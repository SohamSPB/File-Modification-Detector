#!/bin/bash
########		Constants		########
########		Functions	########
function printversion
{
	echo "filemoddetect 0.0.1alpha"
}
function about
{
	clear
	#animate name
	echo "File Modification Detector"
	for i in {232..256} {255..232} ; #232
	 do
		echo -e "\e[0K\r" "\e[38;5;${i}m\t\t\tWritten by Soham Bagayatkar\e[0m";
		echo -en "\e[1A";
		sleep .05;
	 done; 
	echo
	echo -en "\e[1A";
	echo -e "\e[0K\r";
}
function usage
{
cat << EOF
Usage: 
  filemoddetect [OPTION...] [FILE...] - File Modification Detector

Help Options:
  -h, --help				Show help options

Application Options:
  -l, --disablelog			Disables logmode
  -er, --disablerec			Enables recursive mode
  -c, --disablecolor			Disables Colour Output
  -e, --exclude=FILE			Excludes file or directory
  -d, --disablesize			Disables the counting of size of excludes file or directory
  -r,  --rename=PREFIX	Sets prefix for renaming
  -rm,  --renamem=MIDDLE	Sets middle name for renaming
  -rs,  --renames=SUFFIX	Sets suffix for renaming
  -s, --silent				Disables grand md5 generation
  -a, --about				Show About
  -v, --version				Show release version

Examples:
  filemoddetect /home/user/test		Creates md5checksums of each content in /home/user/test folder to current working directory.
  filemoddetect						Create md5checksums of each content current directory in current directory.

EOF
: <<'end_long_comment'
GNU coreutils online help: <http://www.gnu.org/software/coreutils/>
Full documentation at: <http://www.gnu.org/software/coreutils/cat>
or available locally via: info '(coreutils) cat invocation'
end_long_comment
}

function centerQ {
	textsize=${#1}
	width=$(tput cols)
	span=$((($width + $textsize) / 2))
	printf "%${span}s\n" "$1"
}

function printinthree {
	leftstr="$1";    midstr="$2";    rightstr="$3"
	width=$(tput cols)
	#    let COLCEN=$((($width + ${#midstr}) / 2))-${#leftstr}
	#    let COLR=$width-$((($width + ${#midcol}) / 2))+${#rightcol}-${#rightstr}
	if [ -z "$4" ]; then
		leftsetcol=$defcol
		leftcol="${leftstr}"
	else
		leftsetcol=$4
		leftcol="$leftsetcol${leftstr}$nc"
	fi
	if [ -z "$5" ]; then
		midsetcol=$defcol
		midcol="${midstr}"
	    let COLCEN=$((($width + ${#midstr}) / 2))-${#leftstr}
	else
		midsetcol=$5
		midcol="$midsetcol${midstr}$nc"
	    let COLCEN=$((($width + ${#midstr}) / 2))+${#leftcol}-${#leftstr}-${#leftstr}
	fi
	if [ -z "$6" ]; then
		rightsetcol=$defcol
		rightcol="${rightstr}"
	    let COLR=$width-$((($width + ${#midcol}) / 2))
	else
		rightsetcol=$6
		rightcol="$rightsetcol${rightstr}$nc"
	    let COLR=$COLCEN-1
	fi
	#    leftcol="$leftsetcol${leftstr}$nc"
	#    midcol="$midsetcol${midstr}$nc"
	#    rightcol="$rightsetcol${rightstr}$nc"
	printf "%s%${COLCEN}s%${COLR}s\n" "$leftcol" "$midcol" "$rightcol"
}

########		MAIN		########
logmode=true
#logfile="md5hashchecklog.txt"
colmode=true
recmode=false
silentmode=false
excludeon=false
excludefile=""
disablesize=false
filepath="$1"
optionerror=false
failedbyfirst=false
logat=$(date +"%m-%d-%y--%T")
logname="$filepath/${logat}log.txt"

if [ $colmode = true ]; then
	black='\033[0;30m';		dgray='\033[1;30m';		red='\033[0;31m'
	lred='\033[1;31m';		green='\033[0;32m';		lgreen='\033[1;32m'
	brownorange='\033[0;33m';	yellow='\033[1;33m';		blue='\033[0;34m'
	lblue='\033[1;34m';		purple='\033[0;35m';		lpurple='\033[1;35m'
	cyan='\033[0;36m';		lcyan='\033[1;36m';		lgray='\033[0;37m'
	white='\033[1;37m';
	
	fg_black=$(tput setaf 0);	fg_red=$(tput setaf 1);		fg_green=$(tput setaf 2)
	fg_yellow=$(tput setaf 3);	fg_blue=$(tput setaf 4);	fg_magenta=$(tput setaf 5)
	fg_cyan=$(tput setaf 6);	fg_white=$(tput setaf 7)

	bg_black=$(tput setab 0);	bg_red=$(tput setab 1);		bg_green=$(tput setab 2)
	bg_yellow=$(tput setab 3);	bg_blue=$(tput setab 4);	bg_magenta=$(tput setab 5)
	bg_cyan=$(tput setab 6);	bg_white=$(tput setab 7)
fi
nc='\033[0m' # No Color
revcol=$(tput rev)
	
blink=$(tput blink);		bold=$(tput bold);		dim=$(tput dim);	nc=$(tput sgr0)
defforcol=$(tput setaf sgr9);	defbackcol=$(tput setab sgr9)

if [[ $1 != "" ]]; then
	echo
fi

## md5hashcheck $1 $2 $3 $4 $5
IFS=$'\t\n'
if [[ $1 = "" ]]; then
	filepath=$PWD
else
	if [[ -d $filepath ]]; then
		filepath=`readlink -f "$1"`
		shift
	else
		filepath=$PWD
	fi
fi

if [ "$1" != "" ]; then
	while [ "$1" != "" ]; do
	if (( $# >= 1 )); then
		case $1 in
		-l | --disablelog )
			echo -e "${brownorange}logmode is disabled.${nc}"
			logmode=false;;
		-c | --disablecolor)
			echo -e "${lred}Color is disabled.${nc}"
			colmode=false;;
		-s | --silent)
			echo -e "${blue}Silent mode is now enabled.${nc}"
			silentmode=true;;
		-lc | -lc )
			echo -e "${brownorange}logmode & ${lred}color disabled.${nc}"
			logmode=false;		colmode=false;;
		-ls | -sl )
			echo -e "${brownorange}logmode disabled & ${blue}silent mode enabled.${nc}"
			logmode=false;		silentmode=true;;
		-sc | -cs )
			echo -e "${blue}silent mode enabled & ${lred}color disabled.${nc}"
			silentmode=true;	colmode=false;;
		-lsc | -lcs | -csl | -cls | -scl | -slc )
			echo -e "${blue}silent mode enabled & ${brownorange}log, ${lred}color disabled.${nc}"
			silentmode=true;	colmode=false;		logmode=false;;
		-er | --enablerec )
			echo -e "${lblue}recursive mode enabled.${nc}"
			recmode=true;;
		-r | --rename=* )
			if [[ $1 = "--rename="* ]]; then
				pre=${pre:9}
			else
				pre=$2
				shift
			fi
			echo -e "rename prefix set to ${white}${pre}${nc}"
			renamemode=true;;
		-rm | --renamem=* )
			if [[ $1 = "--renamem="* ]]; then
				mid=${mid:9}
			else
				mid=$2
				shift
			fi
			echo -e "rename middle set to ${white}${mid}${nc}"
			renamemode=true;;
		-rs | --renames=* )
			if [[ $1 = "--renames="* ]]; then
				suf=${suf:9}
			else
				suf=$2
				shift
			fi
			echo -e "rename suffix set to ${white}${suf}${nc}"
			renamemode=true;;
		-e | --exclude=* )
			if [[ $1 = "--exclude="* ]]; then
				te=$1; te=${te:10}
				excludefile+=(`readlink -f "$te"`); excludeon=true				
				echo -e "\nExcluding file/directory: ${excludefile[-1]}\n"
			else
				if [[ -z $2 ]]; then
					echo "No argument for $1"
					optionerror=true
				elif [[ $2 == "-u" || $2 == "-d" || $2 == "-f" ]]; then
					echo "Argument for $1 is missing between $1 and $2."
					optionerror=true
				else
					excludefile+=(`readlink -f "$2"`); excludeon=true
					echo -e "\nExcluding file/directory: ${excludefile[-1]}"
					shift
				fi
			fi
			;;
		-d | --disabblesize )
			disablesize=true
			;;
		-a | --about )
		    	about;			exit		;;
		-v | --version )
		    	printversion;		exit		;;
		-h | --help )
			usage;			exit		;;
		-? )
			printf "\nUnknown option $1\n\n"
			usage;		exit;;
		: )
			echo "No argument value for option $1";	usage; exit;;
		* )
			# Should not occur
			if [[ $# = 1 ]]; then
				sleep .01
			else
				echo "Unknown error while processing options"
				usage;		exit 1
			fi
		esac
#		if [[ $# > 1 ]]; then
	    		shift
#		else		break;
#		fi
	 else break;
	 fi
	done
fi
unset $IFS #or IFS=$' \t\n' 

if [[ $excludeon = true ]]; then
	unset excludefile[0]
	excludefile=("${excludefile[@]}")
fi

if [[ $logmode = true ]]; then
	logname="$filepath/${logat}log.txt"
	echo -e "${logat}\t\tProgram started." >> $logname # & pid2=$!
fi

printf "\nCurrent directory $filepath\n\n"

if [[ $logmode = true ]]; then
	logat=$(date +"%m-%d-%y--%T")
	echo -e "${logat}\t\tCurrent directory $filepath" >> $logname 
fi

if [ $optionerror = true ]; then
	exit
fi

if [ $colmode = false ]; then
	black='';		dgray='';		red='';	lred='';		green='';		lgreen='';	brownorange='';	yellow='';		blue='';
	lblue='';		purple='';	lpurple='';	cyan='';		lcyan='';		lgray=''		white='';
	
	fg_black='';	fg_red='';		fg_green=''
	fg_yellow='';	fg_blue='';	fg_magenta=''
	fg_cyan='';	fg_white=''

	bg_black='';	bg_red='';		bg_green=''
	bg_yellow='';	bg_blue='';	bg_magenta=''
	bg_cyan='';	bg_white=''
fi

#check size
if [[ -d $filepath ]]; then
	if [ -r $filepath ]; then
		if [[ $recmode == true ]]; then	
			CHECK="`du -hs $filepath | cut -f1`"
		else
			CHECK="`find $filepath -maxdepth 1 -type f -printf "%s + " | dc -e0 -f- -ep`"
			CHECK="`bc -l<<< 'scale=2;  '$CHECK'/1024/1024/1024'`"
			CHECK="$CHECK G"
		fi
		#CHECK=${CHECK%G*}
		if [[ $recmode == true  ]]; then
			directs=`find $filepath -mindepth 1 -type d | wc -l` # ((directs--))
		fi
	else
		echo -e "Directory '$filepath' has not given ${brownorange}read${nc} permission! (Try using sudo)"
		exit
	fi
elif [[ -f $filepath ]]; then
	echo -e "$filepath is a file."
	exit
else
	echo -e "Directory '$filepath' does ${lred}not exist!${nc}"
	exit
fi
#store total files
IFS=$'\t\n'
regex=".*md5sum[0-3][0-9]-[0-1][0-9]-[0-9][0-9]--[0-2][0-9]:[0-5][0-9]:[0-5][0-9].txt"

if [[ $excludeon = true && $recmode == false ]]; then	#if this condition then maxdepth for function should be 1
	if [[ $excludeon = true ]]; then
		if (( ${#excludefile[@]} < 2 )); then
			files=(`find $filepath -maxdepth 1 -type f -not \( -wholename "*${excludefile[@]:0}*" \) -regextype sed -not -regex "${regex}" `)
		elif [[ ${#excludefile[@]} > 2 ]]; then
			files=(`find $filepath -maxdepth 1 -type f -not \( -wholename "*${excludefile[@]:1}*" \) -regextype sed -not -regex "${regex}" `)
		fi
		if [[ ${#files[@]} = 0  ]]; then
			echo -e "${red}Failed by first method!${nc}"
			files=(`find $filepath -maxdepth 1 -type f \( -regextype sed -not -regex ${regex} \) `)
			if [[ ${#files[@]} = 0  ]]; then
				echo -e "${red}Failed by second method also!${nc}"
				echo
				exit
			else		sleep .01
				echo -e "${green}Second method successfull!${nc}"; failedbyfirst=true; echo;
			fi
		fi
	fi
	
else
	if [[ $excludeon = true ]]; then
		if (( ${#excludefile[@]} < 2 )); then
			files=(`find $filepath -type f -not \( -wholename "*${excludefile[@]:0}*" \) -regextype sed -not -regex "${regex}" `)
		elif [[ ${#excludefile[@]} > 2 ]]; then
			files=(`find $filepath -type f -not \( -wholename "*${excludefile[@]:1}*" \) -regextype sed -not -regex "${regex}" `)
		fi
		if [[ ${#files[@]} = 0  ]]; then
			echo -e "${red}Failed by first method!${nc}"
			files=(`find $filepath -type f \( -regextype sed -not -regex ${regex} \) `)
			if [[ ${#files[@]} = 0  ]]; then
				echo -e "${red}Failed by second method!${nc}"
				echo
				exit
			else		sleep .01
				echo -e "${green}Second method successfull!${nc}"; failedbyfirst=true; echo;
			fi
		fi
	else
		if [[ $recmode == false ]]; then
			files=(`find $filepath -maxdepth 1 -type f \( -regextype sed -not -regex ${regex} \) -a \( -not -path "$filename/${0##./}" \) `)
		else
			files=(`find $filepath -type f \( -regextype sed -not -regex ${regex} \) -a \( -not -path "$filename/${0##./}" \) `)
		fi
	fi
fi
unset $IFS #or IFS=$' \t\n'
#filesfound=find DIR_NAME -type f | wc -l

if (( "${#files[@]}" == "0" )); then
	sleep .01
elif (( "${#files[@]}" == "1" )); then
	echo -en "${blue}${bold}${#files[@]}$nc file found ~ $lblue$bold$CHECK$nc ";
else
	echo -en "${blue}${bold}${#files[@]}$nc files found ~ $lblue$bold$CHECK$nc ";
fi
#	echo -en "${green}${bold}${#files[@]}$nc files found ~ $lblue$bold$CHECK$nc & ${bold}${yellow}${directs}${nc} directories";
if [[ "${directs}" == "0" && "${#files[@]}" == "0" ]]; then
	echo -e "Nothing found!";
	
	if [[ $logmode = true ]]; then
		logat=$(date +"%m-%d-%y--%T")
		echo -e "${logat}\t\tNothing found!" >> $logname 
	fi
	exit
else
	if [[ $recmode = true  ]]; then
		if (( "${directs}" == "0" )); then
			echo -e "No directory";
		elif (( "${directs}" == "1" )); then
			echo -e "${bold}${yellow}${directs}${nc} directory";
		else
			echo -e "${bold}${yellow}${directs}${nc} directories";
		fi
	fi
fi

excludefiles=""
if [ $excludeon = true ]; then
	for exc in ${excludefile[@]}; do
		if [[ -d $exc ]]; then
			if [[ -r $exc ]]; then
				if [[ $disablesize = false ]]; then
					excludelen="`du -hs "$exc" | cut -f1`"
				fi
				IFS=$'\t\n'
				excludefiles=(`find "$exc" -type f`)
				unset $IFS #or IFS=$' \t\n'
			else
				echo -e "Directory '$exc' has not given ${brownorange}read${nc} permission! (Try using sudo)"
				
				if [[ $logmode = true ]]; then
					logat=$(date +"%m-%d-%y--%T")
					echo -e "${logat}\t\tDirectory '$exc' has not given read permission! (Try using sudo)" >> $logname 
				fi
				exit
			fi
		elif [[ -f $exc ]]; then
			if [[ -r $exc ]]; then
				if [[ $disablesize = false ]]; then
					excludelen=`du -hs "$exc" | cut -f1`
				fi
				excludefiles=$exc
			else
				echo -e "File '$exc' has not given ${brownorange}read${nc} permission! (Try using sudo)"
				if [[ $logmode = true ]]; then
					logat=$(date +"%m-%d-%y--%T")
					echo -e "${logat}\t\tFile '$exc' has not given read permission! (Try using sudo)}" >> $logname 
				fi
				exit
			fi
		else
			echo -e "Exclude File/directory '$exc' does ${lred}not exist!${nc}"
			if [[ $logmode = true ]]; then
				logat=$(date +"%m-%d-%y--%T")
				echo -e "${logat}\t\tExclude File/directory '$exc' does not exist!" >> $logname
			fi
			exit
		fi
		
		if [[ $failedbyfirst = true ]]; then
			arrtemp=()
			for i in "${files[@]}"; do
				skip=
				for j in "${excludefiles[@]}"; do
					[[ $i == $j ]] && { skip=1; break; }
				done
				[[ -n $skip ]] || arrtemp+=("$i")
			done
			files=("${arrtemp[@]}")
			arrtemp=""
		fi
		if [[ $disablesize = false ]]; then
			echo "Excluding file/directory $exc is $excludelen in size."
			if [[ $logmode = true ]]; then
				logat=$(date +"%m-%d-%y--%T")
				echo -e "${logat}\t\tExcluding file/directory $exc is $excludelen in size." >> $logname 
			fi
		fi
	done
fi

title="Choose one of the following option" 
#printf "%*s\n" $(((${#title}+$COL)/2)) "$title"
echo
centerQ "$title"
echo
leftstr="1. Create new md5sums"
midstr="2. Verify last md5sums"
rightstr="3. Graphical UI"
printinthree "$leftstr" "$midstr" "$rightstr" "$bg_white$fg_black" "$bg_white$fg_black" "$bg_white$fg_black"
echo "$bg_white$fg_black""4. Rename files""${nc}"
echo -n "Choose option [1-4]: "
#printf "%s%${COL}s\n" "$title" "$green$bold[OK]$nc"

#echo "1. Create new md5sums"
#echo "2. Verify last md5sums"
read

now=$(date +"%d-%m-%y--%T")

#PROGNAME=$(basename $0)
#function error_exit
#{
#	echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
#	exit 1
#}
checkmd=""

if [ "$REPLY" == "1" ]; then
	checkmd="scan"
elif [ "$REPLY" == "2" ]; then
	checkmd="check"
elif [ "$REPLY" == "3" ]; then
	OPTION=$(whiptail --title "MD5HashChecker & Verifier Menu" --menu "Choose your option" 15 60 4 \
	"1" "Create new md5sums" \
	"2" "Verify last md5sums" \
	"3" "View Files" \
	"4" "Rename files" 3>&1 1>&2 2>&3)

	exitstatus=$?
	if [ $exitstatus = 0 ]; then
		if [[ $OPTION = 1 || $OPTION = 4 ]]; then
			if [ "$OPTION" == "4" ]; then
				if [[ $pre = "" && $mid = "" && $suf = "" ]]; then
					echo -e "${lred}Make sure you inserted prefix suffix or middlename for renaming${nc}"
				else
					checkmd="scan"
				fi
			else
				checkmd="scan"
			fi
		elif [ $OPTION = 2 ]; then
			checkmd="check"
		fi
	else
		echo "You choose Cancel."
	fi
elif [ "$REPLY" == "4" ]; then
	if [[ $pre = "" && $mid = "" && $suf = "" ]]; then
		echo -e "${lred}Make sure you inserted prefix suffix or middlename for renaming${nc}"
	else
		checkmd="scan"
	fi
else
	echo -e "${lred}Invalid response!${nc}"
	if [[ $logmode = true ]]; then
		logat=$(date +"%m-%d-%y--%T")
		echo -e "${logat}\t\tInvalid response!" >> $logname 
	fi
fi

if [[ $checkmd = "scan" ]]; then
	starttime=`date +%s`
	canctime=0
	echo -e `tput civis`
	if [[ $renamemode = true ]]; then
		echo "Preparing for renaming..."
	else
		echo "Creating md5sums..."
	fi
	
	if [[ $logmode = true ]]; then
		logat=$(date +"%m-%d-%y--%T")
		if [[ $renamemode = true ]]; then
			echo -e "${logat}\t\tPreparing for renaming..." >> $logname
		else
			echo -e "${logat}\t\tCreating md5sums..." >> $logname
		fi
		echo >> $logname
	fi
	
	filename="$filepath/md5sum$now.txt"
	num=1;	i=0;	errorocc=0;		donesize=0
#	declare -i totsize;	declare -i donesize
#	totsize=`du -sb ${files[@] | cut -f1`;	

	if [[ ( $failedbyfirst = false && ${#excludefile[@]} > 1 ) || ( $failedbyfirst = true && ${#excludefile[@]} > 0 ) ]]; then
#	elif [[ $failedbyfirst = true && ${#excludefile[@]} > 0 ]]; then
		for j in "${excludefile[@]}"; do
			echo "Skipping .... $j" 
			if [[ $logmode = true ]]; then
				logat=$(date +"%m-%d-%y--%T")
				echo -e "${logat}\t\tSkipping .... $j" >> $logname 
				echo >> $logname
			fi
		done
	fi

	for i in ${files[@]};	do
		if [ -f $i -a -r $i ]; then
#			if [ -s $i ]; then
			((totsize+=`du -sb $i | cut -f1`))
#		else	#			echo "File exists but empty"	#		fi
		else
			echo -e "${lred}File $i does not exist!${nc}"
			if [[ $logmode = true ]]; then
				logat=$(date +"%m-%d-%y--%T")
				echo -e "${logat}\t\tFile $i does not exist!" >> $logname 
			fi
		fi
	done
	echo
#	for i in ${files[@]}
	if [ $(dpkg-query -W -f='${Status}' pv 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
		echo "pv is not installed. Install pv for viewing progressbar for huge files. (sudo apt-get install pv)"
		pvnoins=true
		if [[ $logmode = true ]]; then
			logat=$(date +"%m-%d-%y--%T")
			echo -e "${logat}\t\tWarning: pv is not installed." >> $logname
		fi
#		read canc "Do you want to insta"
	fi

	if (( "${#files[@]}" >= "1" )); then
	noexit=true
	while ($noexit); do
	  if (( "$num" <= "${#files[@]}" )); then
		trap ctrl_c INT
		function ctrl_c() {
			temptime=`date +%s`
			echo  #-e "\e[0K\r"
			echo -en `tput cnorm`
			echo -en "\e[0K\r${nc}${revcol}Are you sure want to quit [${nc}${bold}${fg_red}${bg_white}(Y)es${nc}${bg_white}${fg_black}/${nc}${bold}${fg_green}${bg_white}(n)o${nc}${revcol}]:${nc} "
			read canc
			if [[ $canc == 'Y' ]]; then
				echo -e "\r${lred}Cancelled......${nc} @ ${percent}%\n\n"
				if [[ $logmode = true ]]; then
					logat=$(date +"%m-%d-%y--%T")
					echo -e "${logat}\t\tCancelled......" >> $logname 
				fi
				temptime2=`date +%s`
				temptime=$(($temptime2 - $temptime))
				((canctime+=temptime))
				noexit=false	#				break
			else
				echo -e "\r${lgreen}Resumed........${nc}"

				if [[ $logmode = true ]]; then
					logat=$(date +"%m-%d-%y--%T")
					echo -e "${logat}\t\tResumed......" >> $logname 

					if [[ $renamemode = true ]]; then
						echo -e "${lred}Last renaming of ${files[$((num-1))]} is failed!........${nc} (Reason: Due to inturruption)"  2>&1 | tee -a $logname
						echo -e "${lcyan}Renaming last file........${nc}" 2>&1 | tee -a $logname
					else
						echo -e "${lred}Last md5sum calculation of ${files[$((num-1))]} is failed!........${nc} (Reason: Due to inturruption)"  2>&1 | tee -a $logname
						echo -e "${lcyan}Recalculating last md5sum........${nc}" 2>&1 | tee -a $logname
					fi

				else
					if [[ $renamemode = true ]]; then
						echo -e "${lred}Last renaming of ${files[$((num-1))]} is failed!........${nc} (Reason: Due to inturruption)"  
						echo -e "${lcyan}Renaming last file........${nc}" 
					else
						echo -e "${lred}Last md5sum calculation of ${files[$((num-1))]} is failed!........${nc} (Reason: Due to inturruption)"  
						echo -e "${lcyan}Recalculating last md5sum........${nc}" 
					fi

				fi
#				((num--))
				((donesize-=cursize))
				echo -en `tput civis`
				temptime2=`date +%s`
				temptime=$(($temptime2 - $temptime))
				((canctime+=temptime)) #				continue
			fi
		}
		percent=$((${donesize}*100/${totsize})); endtime=`date +%s`; endtime=$(( $endtime - $starttime - $canctime )); endtime=`date -u -d @$endtime +"%T"`

		echo -e "\e[0K\r${fg_green}Processing $num of ${#files[@]} \t\t Overall by size: ${percent}% Time Elapsed: $endtime";
		echo -e "\e[0K\rProcessing.... ${files[num-1]}";

		if [[ $logmode = true ]]; then
			logat=$(date +"%m-%d-%y--%T")
			echo -e "${logat}\t\tProcessing.... ${files[num-1]}" >> $logname
		fi
						
		if [ -f ${files[num-1]} -a -r ${files[num-1]} ]; then
			cursize=`du -sb ${files[num-1]} | cut -f1`
			if [[ $renamemode = true ]]; then
					if [[ $mid = "date" ]]; then
						modDate=$(date -d $(stat -c "%y" "${files[$((num-1))]}" ) "+%Y-%m-%d_%H:%M:%S")
						midtmp=$modDate
					else
						midtmp=$mid
					fi
	#				modDate=$(date -r "${files[$((num-1))]}" )
	#				modDate=${modDate%%.*}
					filenm=${files[$((num-1))]}
					filepth=$( dirname $filenm} )
					extn=${filenm##*.}
	#				pre="IMG_"
					echo -e "${files[$((num-1))]} to $filepth/$pre$midtmp$suf.$extn"
					$( mv "${files[$((num-1))]}" "$filepth/$pre$midtmp$suf.$extn" )
					if [[ $logmode = true ]]; then
						logat=$(date +"%m-%d-%y--%T")
						echo -e "${logat}${summ}\t${files[$((num-1))]}" >> $logname
						echo -e "${logat}${files[$((num-1))]}\tto\t$filepth\\$filepth/$pre$midtmp$suf.$extn" >> $filename
					fi
			else
				if [[ $pvnoins = true ]]; then
						($(md5sum "${files[$((num-1))]}" >> $filename ))
				else
						summ=($(pv "${files[$((num-1))]}" | md5sum ))
						summ=${summ::-3}
						echo -e "${summ}\t${files[$((num-1))]}" >> $filename
				fi
				if [[ $logmode = true ]]; then
					logat=$(date +"%m-%d-%y--%T")
					echo -e "${logat}\t\t${summ}\t${files[$((num-1))]}" >> $logname
				fi
			fi
		else
			echo -e "File ${files[num-1]} does not exist!"
			if [[ $logmode = true ]]; then
				logat=$(date +"%m-%d-%y--%T")
				echo -e "${logat}\t\tFile ${files[num-1]} does not exist!" >> $logname 
			fi
			((errorocc++))
			thisfilefailed=true
		fi
		((donesize+=cursize))
#		echo -e "\e[0K\r `date`" &
#		(for w in {1..10}
#		  do
#			sleep 1; echo -e "\e[0K\rWait... `date`"; echo -en "\e[1A";
#		done ) & pid1=$!
# tar -czf - ./Documents/ | (pv -n > backup.tgz) 2>&1 | dialog --gauge "Progress" 10 70
#		sleep 1
#		wait $pid2
		echo -en "${nc}\e[1A";
		echo -en "\e[1A";
		echo -en "\e[1A";

		if [[ $logmode = true ]]; then
			echo >> $logname
		fi
		
		if [[ $thisfilefailed = true ]]; then
			echo -e "\e[0K\r${lred}Processing of ${files[num-1]}${nc} failed!"
			if [[ $logmode = true ]]; then
				echo -e "${logat}\t\tProcessing of ${files[num-1]} failed!" >> $logname
			fi
		elif [[ $canc != "Y" ]]; then
			echo -e "\e[0K\rProcessed.... ${files[num-1]}"
		fi
		thisfilefailed=false
		((num+=1))
	elif (( "$num" > "${#files[@]}" )); then
		((num--))
		break;
	fi
	done
	if [ "$canc" != "Y" ]; then
#		echo -en "\e[1A";
		if (( "$errorocc" > "0" )); then
			echo -e "\e[0K\rTotal ${yellow}"$((num-errorocc))"${nc} of ${#files[@]} processed. ${lred}${errorocc} failed!${nc}" 
		else
			echo -e "\e[0K\rTotal $num of ${#files[@]} processed."
		fi

		endtime=`date +%s`
		elapsed=$(( $endtime - $starttime - $canctime ))
#		elapsed=`echo "scale=8; ($endtime - $starttime) / 1000000000" | bc`

		if [[ $elapsed > 59 ]]; then
			echo -e "\e[0K\r$(($elapsed / 60)) minutes and $(($elapsed % 60)) seconds elapsed."
		else
			echo -e "\e[0K\rTotal time elapsed $elapsed seconds"
#			echo -e "\e[0K\r"`date -u -d @$elapsed +"%T"`
		fi

		if [[ $silentmode = false && $renamemode = false ]]; then
			echo -e "\e[0K\rGenerating grandmd5sum ...."
			if [[ $logmode = true ]]; then
				logat=$(date +"%m-%d-%y--%T")
				echo -e "${logat}\t\tGenerating grandmd5sum ...." >> $logname
			fi
		
			($( find $filepath -type f \( -name "md5sum*.txt" \) -exec md5sum {} + > $filepath/grandmd5sum$now.txt ))
		fi
		#files=(`find $filepath -type f \( -regextype sed -not -regex ${regex} \) `)
#		echo "Tabbing outputfile....."
#		sed 's/ \+ /\t/g' $filename > "tmp$now.txt"
#		($(rm $filename))
#		($(mv "tmp$now.txt" "$filename"))
		echo "Finishing....."
		echo -e "${lgreen}Done${nc}"
		if [[ $logmode = true ]]; then
			logat=$(date +"%m-%d-%y--%T")
			echo -e "${logat}\t\tFinishing....." >> $logname
			echo -e "${logat}\t\tDone" >> $logname
		fi
		echo
	fi
	elif [ ${#files[@]} -eq 0 ]; then
		echo "${fg_yellow}No files found!${nc}";
	fi
	echo -en `tput cnorm`

elif [[ $checkmd = "check" ]]; then
	regex=".*\/md5sum[0-3][0-9]-[0-1][0-9]-[0-9][0-9]--[0-2][0-9]:[0-5][0-9]:[0-5][0-9].txt"
	clear
	INSTALLED=$(dpkg -l \grep wmctrl)
	if [ "$INSTALLED" != "" ]; then
		`wmctrl -r :ACTIVE: -b toggle,maximized_vert,maximized_horz`
	else
		echo "wmctrl is not installed. Switch to full screen manually for better view. (sudo apt-get install wmctrl)"
	fi
	files=(`find $filepath -type f \( -regextype sed -regex ${regex} \) `)
#sortedfiles
	sfiles=( $( printf "%s\n" "${files[@]}" | sort -nr ) )
	currentfile=${sfiles[0]}
	lastfile=${sfiles[1]}
	if [[ -n "$lastfile" && -n "$currentfile" ]]; then
		echo -e "Comparing files..... \t ${green}$currentfile${nc} \t and \n\t\t\t ${green}$lastfile.${nc}"
#		echo "`diff -Fxvf $currentfile $lastfile`"
#		echo -e "\n`cut -f 2 $currentfile`"
#		newen="`cut -f 2 $currentfile`"

#		changes=($(sdiff <(sort $currentfile) <(sort $lastfile) | grep "|" | sed 's/|/is changed to/g'))
#		echo -e "${yellow}Files changed: "$(((${#changes[@]})/5))"${nc}"
#		forward=0
## +1 2 3 4 5 +6 7 8 9 10 +11 12 13 14 15......
#		for i in ${changes[@]}; do
#		if (( "$forward" < "${#changes[@]}" )); then
#			echo -e "${changes[forward]}\t\t${changes[forward+1]}\t${dgray}${changes[forward+2]}${nc}\t\t${changes[forward+3]}\t\t${changes[forward+4]}"
#			((forward+=5))
#		else
#			break
#		fi
#		done

#		changes=($(sdiff <(sort $currentfile) <(sort $lastfile) | grep "<")) #| sed 's/|/is changed to/g'))
		changes=($(cut -f2 $lastfile)) #| sed 's/|/is changed to/g'))
#		echo ${changes[@]}
		changes2=($(cut -f2 $currentfile)) #| sed 's/|/is changed to/g'))
#		echo ${changes2[@]}

		newfiles=${changes2[@]}			# new files
		for del in ${changes[@]}; do
		   newfiles=(${newfiles[@]/$del})
		done
		if ((  ${#newfiles[@]} > 0 )); then
			echo -e "${green}Newly created Files (${#newfiles[@]})${nc}"
			for i in ${newfiles[@]}; do
				echo $i
			done				#  end  newfiles
		else
			echo -e "${green}No new files created${nc}"
		fi

		oldfiles=${changes[@]}			# new files
		for del in ${changes2[@]}; do
		   oldfiles=(${oldfiles[@]/$del})
		done
		if ((  ${#oldfiles[@]} > 0 )); then
			echo -e "\n${brownorange}Deleted Files (${#oldfiles[@]})${nc}"
			for i in ${oldfiles[@]}; do
				echo $i
			done				#  end  newfiles#
		else
			echo -e "${green}No files deleted.${nc}"
		fi

#		mdold=($(cut -f1 $currentfile)) #| sed 's/|/is changed to/g'))
#		mdnew=($(cut -f1 $lastfile)) #| sed 's/|/is changed to/g'))
		l2="${changes2[*]}"                    # add framing blanks
		for item in ${changes[@]}; do
		  if [[ $l2 =~ "$item" ]] ; then    # use $item as regexp
		    comfiles+=($item)
		  fi
		done
#		echo  ${comfiles[@]}		#comfiles
#		echo ${#comfiles[@]}		#comfiles
		numm=${#comfiles[@]}		#comfiles
		i=0
		while true; do
			if (( $i >= $numm)); then
				break
			fi
			var1=`grep ${comfiles[i]} $lastfile | awk '{print $1;}'`
			var2=`grep ${comfiles[i]} $currentfile | awk '{print $1;}'`
			if [[ "$var2" != "$var1" ]]; then
				mdold+=($var1);		mdnew+=($var2)
			else unset comfiles[$i]; 	#mdold+=;	mdnew+=
			fi
			((i++))
		done
		comfiles=( "${comfiles[@]}" )

		declare -A matrix
		num_rows=${#mdold[@]}
		num_columns=3
		for ((i=0;i<=num_rows;i++)) do
			matrix[$i,1]=${comfiles[$i-1]}
			matrix[$i,2]=${mdold[$i-1]}
			matrix[$i,3]=${mdnew[$i-1]}
		done

		f1="%$((${#num_rows}+1))s";		f2="%50s"
		printf "$f1" ''
		for ((i=1;i<=num_columns;i++)) do
		    printf "$f2" $i
		done
		echo

		for ((i=1;i<=num_rows;i++)) do
		    printf "$f1" $i
		    for ((j=1;j<=num_columns;j++)) do
			printf "$f2" ${matrix[$i,$j]}
		    done
		    echo
		done
	else
		echo "No files found for md5sum comparision."
	fi
#        error_exit "$LINENO: An error has occurred."
	echo
#	fgrep -vxf before.txt after.txt

#n=$(cat $currentfile | wc -l)
#cat $currentfile | {
#  i=0 bad=0
#  while IFS= read -r line; do
#    i=$((i+1))
#    echo "Checking file $i/$n: $line"
#    echo "$line" | md5sum -c - || bad=$((bad+1))
#  done
#  [ $bad -eq 0 ] || { echo "$bad bad checksums"; false; }
#}
fi

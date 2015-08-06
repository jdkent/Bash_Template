#!/usr/bin/env bash

############################################################
# Bash Settings
############################################################
#These are settings to help a script run "cleanly"
set -o errexit #exits script when a command fails
set -o pipefail #the exit status of a command that returned a non-zero exit code during a pipe
set -o nounset #exit the script when you try to use undeclared variables
#set -o xtrace #prints out the commands a they are called, (for debugging)


############################################################
# Functions
############################################################
#What to run when user presses "control C" (kill script)
function control_c 
{
	echo -e "\n## Caught SIGINT: Cleaning up before exit"
	#rm intermediate files or partial outputs
	exit $?
}


function clobber
{	
	#Tracking Variables
	local -i num_existing_files=0
	local -i num_args=$#

	#Tally all existing outputs
	for arg in $@; do
		if [ -e "${arg}" ] && [ "${clob}" == true ]; then
			rm "${arg}"
		elif [ -e "${arg}" ] && [ "${clob}" == false ]; then
			num_existing_files=$(( ${num_existing_files} + 1 ))
			continue
		elif [ ! -e "${arg}" ]; then
			continue
		else
			echo "How did you get here?"
		fi
	done

	#see if command should be run
	#0=true
	#1=false
	if [ ${num_existing_files} -lt ${num_args} ]; then
		return 0
	else
		return 1
	fi

	#example usage
	#clobber test.nii.gz &&\
	#fslmaths input.nii.gz -mul 10 test.nii.gz
}

function command_check
{
	local arg="${1}"
	command -v "${arg}" > /dev/null 2>&1 || \
	{ echo >&2 "${arg} was not found, exiting script"; exit 1; }
	#else
	return 0
}


function printhelp
{
	echo "this is where you would place usage information"
	echo "test.sh -i <input> -o <ouput> -h (optional) -c (optional)"
	echo "-i <input>: the name of the input, (let the user know how the input should look)"
	echo "-o <output>: the name of the output, (let the user know how the output should look)"
	echo "-h: displays this helpful message"
	echo "-c: clobber (overwrites the output)"
	echo "if you have any questions or comments please email username@email.edu"
	exit 1
}


############################################################
# Job Control Statements
############################################################
#trap (or intercept) the control+C command
trap control_c SIGINT
trap control_c SIGTERM





############################################################
# Variable Defaults
############################################################
clob=false




############################################################
# Variable setting and checking
############################################################

#See if any arguments were passed into this script
if [ $# -eq 0 ]; then
	printhelp
fi


#Set the inputs we are looking
while getopts "i:o:hc" OPTION; do
	case $OPTION in
		i)
			input="${OPTARG}"
			;;
		o)
			output="${OPTARG}"
			;;
		h)
			printhelp
			;;
		c)
			clob=true
			;;
		*)
			printhelp
			;;
	esac
done


if [ -z ${input+x} ]; then
	echo "-i <input> is unset, printing help and exiting"
	printhelp
fi

if [ -z ${output+x} ]; then
	echo "-o <output> is unset, printing help and exiting"
	printhelp
fi

############################################################
# Program/command Checking
############################################################
#These are commands that are necessary to run the script

#should use for specialized packages (like fsl or afni)
#normally don't need to check basic commands like these
 command_check touch
 command_check sleep



############################################################
# main()
############################################################
#This is where all the main commands (commands that actually do what you want) are located


#Look at me count things and make useless files!

for number in $(seq 1 ${input}); do
	clobber "${output}"_${number}.txt &&\
	touch "${output}"_${number}.txt
	sleep 2
done
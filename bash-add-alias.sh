#!/bin/bash


## Dubugging:
## set -x
## Errors exit immediately:
## set -e
## Catch undefined vars:
set -u


green_light="\e[1;32m"
yellow='\e[1;33m'
red='\e[1;31m'
default_colour="\e[00m"


## Leave no trace after exit (except alias(es)):
function cleanup_vars()
	{
	unset value
	unset httpdUser
	unset user_name
	unset home_dir
	unset aliasExists
	unset phpFound
	unset answer
	unset aliasString
	unset addAlias
	unset aliasExists

	unset getHttpdUser_old
	unset getHttpdUser
	unset occOwner
	unset occPath
	unset getOccPath

	unset green_light
	unset yellow
	unset red
	unset default_colour

	## Reset all trap signals:
	trap - SIGINT
	trap - SIGHUP
	trap - SIGTERM
	## trap - HALT
	trap - SIGKILL
	trap - EXIT
	trap - QUIT
	trap - RETURN
	## If param was passed, i.e. "ALL", cleanup EVERYTHING, we're done:
	if [[ ${#@} -ge 1 ]]; then
		## read -p "cleaning up vars, finally cleanup_vars() itself..." answer
		## unset answer
		unset cleanup_vars
		## Reset unbound var checking, else i.e. bash completion breaks, etc.
		set +u
	fi
	## This hangs around if run via ". $this_script" and needs to be
	## manually cleared.
	## Putting *entire* script (after func defs) inside subshell fixed it:
	## trap - RETURN
	}

function getHttpdUser()
	{
	## Fetch possible httpd users (for sudo -u ...) into array:
	##
	## Params: regex / string of name(s) to search for
	while read value; do
		## Associative array:
		## httpdUser[$value]=$value
		## Normal, indexed array:
		httpdUser+=($value)
	done <<< $(grep													  \
		--extended-regex												\
		--ignore-case														\
		--only-matching													\
		--max-count=1														\
		"${1}" /etc/passwd											\
		)
	}


function getHttpdUser_old()
	{
	read -a httpdUser <<< $(grep							\
		--extended-regex												\
		--ignore-case														\
		--only-matching													\
		"(httpd|www-data|nobody)" /etc/passwd		\
		)
	}


function getOccPath()
	{
	read -ep "Path to occ: " -i "/" occPath
	if [[ ! -f ${occPath} ]] ; then
		getOccPath
	fi
	echo "occPath: \"${occPath}\""
	}


function bash_aliases()
	{
#	echo "PARM COUNT: $#"
	if [[ $# -eq 0 ]] ; then
		return 99
	else
#		echo "PARM COUNT: ${#}:  \"$1\""
		home_dir=${1}
	fi

	grep "occ" ${home_dir}/.bash_aliases
	aliasExists=$?
	if [[ aliasExists -eq 0 ]]; then
		echo "There is an \"occ\" alias in ${home_dir}.bash_aliases:"
		grep "occ" ${home_dir}/.bash_aliases
	elif [[ -w ${home_dir}/.bash_aliases ]]; then
${default_colour}
		echo -en "Add alias to ${yellow}${home_dir}/.bash_aliases${default_colour}?"
		read -s -p " (y/N) " -n 1 answer
		if [[ ${answer} =~ ^Y|y ]] ; then
			echo "Y"
			echo "${aliasString}" >> ${home_dir}/.bash_aliases
		else
	##	if [[ ${answer} != "" ]] ; then
			echo "N"
		fi
	fi
	}




## Run EVERYTHING in a subshell so "trap ... RETURN" doesn't linger:
## (
## Cleanup all variables on exit:
## trap 'cleanup_vars' SIGINT SIGKILL SIGTERM
## Cleanup ALL variables on exit (including cleanup_vars() itself):
trap 'cleanup_vars ALL' RETURN EXIT QUIT SIGINT SIGKILL SIGTERM


## Store web server user name(s) from /etc/passwd as indexed array:
## declare -A httpdUser
declare -a httpdUser

## Find the web server user name:
getHttpdUser "httpd|www-data"
if [ ${#httpdUser[0]} -eq 0 ] ; then
	## No standard httpd user found, try "nobody":
	getHttpdUser "nobody"
fi


if [ ${#httpdUser[0]} -eq 0 ] ; then
	echo -e "${yellow}WARNING${default_colour}: No web server user found."
	return 1
else
	echo -ne "Web server user name: "
	echo -e "\"${green_light}${httpdUser[0]}${default_colour}\"."
fi


## Looks for existing occ alias:
alias occ 2>/dev/null
aliasExists=$?
## USER=root, HOME=/root, SUDO_USER=me: 
## user_name=${SUDO_USER:-$USER}
user_name=${USER:-$SUDO_USER}
if [ ${aliasExists} -eq 0 ] ; then
	echo "Alias for occ found for user \"${user_name}\"."
	aliasString=$(alias occ)
else
	echo "Alias for occ command not found for user \"${user_name}\"."
	which php 2>&1 > /dev/null
	phpFound=$?
	if [ $phpFound -ne 0 ]; then
		echo -e "${red}ERROR${default_colour}: php not found in path."
		kill -s SIGKILL $$
	fi
	occPath="$(pwd)/occ"
	if [[ -f ${occPath} ]] ; then
		occPath=$(pwd)/occ
	else
		echo "Can't find \"occ\", not in current directory."
		getOccPath
	fi
	occOwner=$(stat --format="%U" ${occPath})
	if [[ ${occOwner} != ${httpdUser[0]} ]] ; then
		echo -e "${red}ERROR${default_colour}: Owner of occ is not web server user:"
		echo "	${occOwner} != ${httpdUser}"
		kill -s SIGKILL $$
##		return 99
	fi

	aliasString="occ='sudo --user ${httpdUser} php ${occPath}'"
	echo -ne "Run \"${yellow}alias ${green_light}${aliasString}${default_colour}\""
#	read -s -p "Run \"alias ${aliasString}\" (y/N)? " -n 1 answer
	read -s -p " (y/N)? " -n 1 answer
	if [[ ${answer} =~ ^[Yy] ]] ; then
		echo "Y"
		eval alias "${aliasString}"
		alias occ
##	elif [[ ${answer} != "" ]] ; then
	else
		echo "N"
	fi
fi

## Is there an occ alias in ~/.bash_aliases?
bash_aliases $HOME
home_dir=""
if [[ "${SUDO_USER}" != "" ]] ; then
	## Find user-who-ran-sudo's home directory:
	home_dir=$(grep ${SUDO_USER} /etc/passwd)
	## Strip off colon->end-of-line
	home_dir=${home_dir%:*}
	## Strip off start-of-line->last colon:
	home_dir=${home_dir##*:}
	if [[ "$HOME" != "${home_dir}" ]] ; then
		bash_aliases ${home_dir}
	fi
fi



cleanup_vars ALL
trap - RETURN
trap -p RETURN
echo "DONE."
## echo "Run \"trap -p\" to see if there's an existing trap on return"
## echo "If so, run \"trap - RETURN\" to clear it."
## )	## end sub-shell

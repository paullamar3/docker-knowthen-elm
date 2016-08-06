#!/bin/bash

## An "entrypoint" script for the docker-knowthen-elm container

set -e

USAGE="$(basename "$0") [-h] [-u USER] [-U UID] [-G GID] 
                     [-g GIT_NAME] [-e GIT_EMAIL]
		     [-d MEDIA_FOLDER]
		     [ARGS]

This script starts a bash shell inside a container that holds the Elm programming
language and the atom editor. It supports some optional arguments
to customize the shell environment so that the user's information carries into 
the container and so that the container can use the user's X windows. 

     -h            Display this help message.

     -u USER       Name of new user container should use.

     -U UID        ID of new user container should use.

     -G GID        ID of the group created for the new user.

     -g GIT_NAME   The Git global user.name for the new user.

     -e GIT_EMAIL  The Git global user.email for the new user.

     ARGS          Additional arguments to pass into Vim.

"

# First set up the default values for the options.
new_user=""
new_uid=""
new_gid=""
git_nm=""
git_email=""
workdir=""

# Parse any options
while getopts ":hu:U:G:g:e:d:" opt; do
	case $opt in
		h) 
			echo "$USAGE"
			exit
			;;
		u)
			new_user="$OPTARG"
			;;
		U)
			new_uid="-u $OPTARG"
			;;
		G)
			new_gid="-g $OPTARG"
			;;
		g)
			git_nm="$OPTARG"
			;;
		e)
			git_email="$OPTARG"
			;;
		d)
			workdir="/media/$OPTARG"
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 1
			;;
	esac
done

if [ -n "$new_user" -a -z "$( getent passwd $new_user )" ]; then
	p_adduser "$new_uid" "$new_gid" "$new_user" "$new_user"
elif [ -z "$new_user" -a ! -f /root/initialized ]; then
	touch /root/initialized
fi

if [ -n "$git_nm" -a -n "$git_email" -a -z "$( git config user.name )" ]; then
	if [ -n "$new_user" ]; then
		# We have to be in the users home folder (or a subdirectory) for 
		# the 'git config' command to work.
		set -x
		cd /home/$new_user
		runuser -u "$new_user"  -- git config --global user.name "$git_nm"
		runuser -u "$new_user"  -- git config --global user.email "$git_email"
		set +x
	else
		git config --global user.name "$git_nm"
		git config --global user.email "$git_email"
	fi
fi

if [ -n "$workdir" ]; then
	cd "$workdir"
fi

if [ -n "$new_user" ]; then 
	gosu "$new_user" atom
	gosu "$new_user" bash
else
	exec bash
fi


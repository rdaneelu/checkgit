#!/bin/bash

fp=()
file_checkgit="$HOME/.config/.checkgit" # Change the path to your file here if you like it elsewhere
mode=0
msj=""
red="\033[0;31m"
green="\033[0;32m"
nc="\033[0m"

read -p "Check also for untracked files on your repos? (Y/n): " yn
if [[ $yn == "y" || $yn == "Y" || $yn == "" ]];then
    yn=normal
elif [[ $yn == "n" || $yn == "N" ]]; then
    yn=no
else
    echo "Wrong option!! quitting..."
    exit 1
fi

# TEST if checkgit or .gitconfig or .config/git/config exist
# Also saves either path for repos or its alias, and saves the name of the repo
# fp = full path to repo
if [ -f $file_checkgit ]; then
    # Read all directories
    fp=( $(cat $file_checkgit | sed 's/\/$//') )
    # Remove duplicates
    read -a fp <<< `printf "%s\n" "${fp[@]}" | sort -u | sed -z 's/\n/ /g'`
    mode=1
else
    echo no config file for git found! Quitting...
    exit 2
fi

#
if [ $mode -eq 1 ]; then
    echo Fetching all repositories... Please WAIT!
    for (( i = 0; i < ${#fp[@]}; i++ )); do

        # Fetch all repos
        git --git-dir=${fp[$i]}/.git --work-tree=${fp[$i]} fetch --all -q
        [ $? -ne 0 ] && exit 1

        msj="${msj}"`dirname "${fp[$i]}/.git"`": "
        if [[ $(git --git-dir=${fp[$i]}/.git --work-tree=${fp[$i]} rev-parse HEAD) != $(git --git-dir=${fp[$i]}/.git --work-tree=${fp[$i]} rev-parse @{u}) ]];then
            if git --git-dir=${fp[$i]}/.git --work-tree=${fp[$i]} log --pretty=oneline | awk '{print $1}' | grep -Fq $(git --git-dir=${fp[$i]}/.git --work-tree=${fp[$i]} rev-parse @{u});then
                msj="${msj}${red}Upstream Behind Local${nc}"
            else
                msj="${msj}${red}Upstream Ahead of Local${nc}"
            fi
            if [ $(git --git-dir=${fp[$i]}/.git --work-tree=${fp[$i]} status --porcelain --untracked-files=$yn | wc -l) -ne 0 ];then
                msj="${msj}, ${red}Local Changes${nc}"
            fi
        else
            if [ $(git --git-dir=${fp[$i]}/.git --work-tree=${fp[$i]} status --porcelain --untracked-files=$yn | wc -l) -eq 0 ];then
                msj="${msj}${green}ALL OK${nc}"
            else
                msj="${msj}${red}Local Changes${nc}"
            fi
        fi
        msj="${msj}\n"
    done
fi
echo -e "\nREPOSITORIES:"
echo -e "${msj}"

#!/bin/bash

repos_names=() # array for the repositories names only
fp=() #array for the full path of the directory of the repositories
config_file=$HOME/.config/.checkgit # Change the path to your file here if you like it elsewhere
msj="" # The whole output is stored here
red="\033[0;31m" # make the output text red
green="\033[0;32m" # make the output text green
nc="\033[0m" # make the output text without color
num_repeated_paths=0

fill_withoutPathDupicates() {
    if [ -f $config_file ]; then
        # local variables for onetime use
        local fp_temp=($(cat $config_file | cut -d '~' -f 1 | sed -e 's/\s*//g' | sed 's/\/$//g'))
        local repos_names_temp=($(cat $config_file | cut -d '~' -f 2))
        local num=${#fp_temp}

        for (( i=0; i < $num-1 ; i++ )); do
            local repeat=false
            for (( j=i+1; j < $num; j++ )); do
                # with a local variable check if there is a dir path that repeats and gives them a 
                # empty string
                if [[ ${fp_temp[$i]} == ${fp_temp[$j]} ]];then
                    [[ ${fp_temp[$i]} == "" ]] && break
                    fp_temp[$j]=""
                    repeat=true
                fi
            done
            $repeat && let num_repeated_paths++
            if [[ "${fp_temp[$i]}" != "" ]];then
                fp+=(${fp_temp[$i]})
                if [[ "${repos_names_temp[$i]}" != "${fp_temp[$i]}" ]];then
                    repos_names+=(${repos_names_temp[$i]})
                else
                    repos_names+=($(echo ${fp_temp[$i]} | sed 's/\/$//g' | rev | cut -d '/' -f 1 | rev))
                fi
            fi
        done
    else
        echo no config file for git found! quitting...
        exit 2
    fi
}
rename_nameDuplicates(){
    for (( i=0; i < ${#repos_names[@]}-1; i++ ));do
        local numrepo=2
        for (( j=i+1; j < ${#repos_names[@]}; j++ ));do
            if [[ ${repos_names[$i]} == ${repos_names[$j]} ]];then
                repos_names[$j]="${repos_names[$i]}$numrepo"
                let numrepo++
            fi
        done
    done
}
check_dir(){
    for i in ${fp[@]};do
        [ -d $i/.git ] || { echo There is no git repository in $i; exit 1;}
    done
}
prompt_untracked_files(){
    read -p "Check also for untracked files on your repos? (Y/n): " yn
    if [[ $yn == "y" || $yn == "Y" || $yn == "" ]];then
        yn=normal
    elif [[ $yn == "n" || $yn == "N" ]]; then
        yn=no
    else
        echo "Wrong option!! quitting..."
        exit 1
    fi
}

prompt_fetch(){
    echo "Fetch upstream repositories?"
    read -p "(Takes longer, choose n if you very recently fetch it) (y/N): " yn2
    if [[ $yn2 == "n" || $yn2 == "N" || $yn2 == "" ]];then
        yn2=false
    elif [[ $yn2 == "y" || $yn2 == "Y" ]]; then
        yn2=true
    else
        echo "Wrong option!! quitting..."
        exit 1
    fi
}
fetch_gitrepos(){
    # Fetch all repos
    local i=$1
    git --git-dir=${fp[$i]}/.git --work-tree=${fp[$i]} fetch --all -q
    [ $? -ne 0 ] && exit 1
}
main(){
    fill_withoutPathDupicates
    rename_nameDuplicates
    check_dir
    prompt_fetch
    echo
    prompt_untracked_files
    $yn2 && echo Fetching all repositories... please WAIT!
    for (( i = 0; i < ${#fp[@]}; i++ )); do
        $yn2 && fetch_gitrepos $i
        msj="${msj}${repos_names[$i]}: "
        num_changes=$(git --git-dir=${fp[$i]}/.git --work-tree=${fp[$i]} status --porcelain --untracked-files=$yn | wc -l)
        [ $num_changes -gt 1 ] && s="s" || s=""
        if git --git-dir=${fp[$i]}/.git --work-tree=${fp[$i]} branch -a | grep -Fq "remotes"; then
            if [[ $(git --git-dir=${fp[$i]}/.git --work-tree=${fp[$i]} rev-parse HEAD) != $(git --git-dir=${fp[$i]}/.git --work-tree=${fp[$i]} rev-parse @{u}) ]];then
                if git --git-dir=${fp[$i]}/.git --work-tree=${fp[$i]} log --pretty=oneline | awk '{print $1}' | grep -Fq $(git --git-dir=${fp[$i]}/.git --work-tree=${fp[$i]} rev-parse @{u});then
                    msj="${msj}${red}Upstream Behind Local${nc}"
                else
                    msj="${msj}${red}Upstream Ahead of Local${nc}"
                fi
                if [ $num_changes -ne 0 ];then
                    msj="${msj}, ${red}Local Changes in $num_changes file$s${nc}"
                fi
            else
                if [ $num_changes -eq 0 ];then
                    msj="${msj}${green}ALL OK${nc}"
                else
                    msj="${msj}${red}Local Changes in $num_changes file$s${nc}"
                fi
            fi
        else
            if [ $num_changes -eq 0 ];then
                msj="${msj}${green}ALL OK${nc} (No upstream repository detected)"
            else
                msj="${msj}${red}Local Changes in $num_changes file$s${nc} (No upstream repository detected)"
            fi
        fi
        msj="${msj}\n"
    done
    echo -e "\nREPOSITORIES:"
    echo -e "${msj}"
}
main

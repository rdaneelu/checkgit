#!/bin/bash

repos_names=()
fp=()
config_file=$HOME/.config/.checkgit # Change the path to your file here if you like it elsewhere
msj=""
red="\033[0;31m"
green="\033[0;32m"
nc="\033[0m"
config_repeat=0

fill_withoutPathDupicates() {
    if [ -f $config_file ]; then
        local fp_temp=($(cat $config_file | cut -d '~' -f 1 | sed -e 's/\s*//g' | sed 's/\/$//g'))
        local repos_names_temp=($(cat $config_file | cut -d '~' -f 2))
        local num=${#fp_temp}
        local num_repeat=0

        for (( i=0; i < $num-1 ; i++ )); do
            local repeat=false
            for (( j=i+1; j < $num; j++ )); do
                if [[ ${fp_temp[$i]} == ${fp_temp[$j]} ]];then
                    [[ ${fp_temp[$i]} == "" ]] && break
                    fp_temp[$j]=""
                    repeat=true
                fi
            done
            $repeat && let num++ 
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
        echo No config file for git found! Quitting...
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
    read -p "(Takes longer, choose n if you very recently fetch it) (Y/n): " yn2
    if [[ $yn2 == "y" || $yn2 == "Y" || $yn2 == "" ]];then
        yn2=true
    elif [[ $yn2 == "n" || $yn2 == "N" ]]; then
        yn2=false
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
        if git --git-dir=${fp[$i]}/.git --work-tree=${fp[$i]} branch -a | grep -Fq "remotes"; then
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
        else
            if [ $(git --git-dir=${fp[$i]}/.git --work-tree=${fp[$i]} status --porcelain --untracked-files=$yn | wc -l) -eq 0 ];then
                msj="${msj}${green}ALL OK${nc} (No upstream repository detected)"
            else
                msj="${msj}${red}Local Changes${nc} (No upstream repository detected)"
            fi
        fi
        msj="${msj}\n"
    done
    echo -e "\nREPOSITORIES:"
    echo -e "${msj}"
}
main

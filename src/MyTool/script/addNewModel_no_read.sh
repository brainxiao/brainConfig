#!/bin/sh 
### this script is used to commit the new model_id
### author:xiaozhitao
### version:1.1.0
### proudly presented by CVTE



PUSH_TIME=0

find_git_branch () {
    local dir=. head
    until [ "$dir" -ef / ]; do
        if [ -f "$dir/.git/HEAD" ]; then
            head=$(< "$dir/.git/HEAD")
            if [[ $head = ref:\ refs/heads/* ]]; then
                git_branch="(${head#*/*/})"
            elif [[ $head != '' ]]; then
                git_branch="(detached)"
            else
                git_branch="(unknow)"
            fi
            return
        fi
        dir="../$dir"
    done
    git_branch=''
}

cdx ()
{
    local g_cur_path=`pwd|tr '/' ' '`;
    local my_path="";
    for i in $g_cur_path;
    do
        my_path=$my_path/$i;
        if [[ ${i/${1}//} != $i ]]; then
            cd $my_path;
            break;
        fi;
    done
}

Is_Empty() {
    if [ "$1" = "" ]
    then
            return 0
    else
            return 1
    fi
}

print_err() {
        echo -e "\033[31m$@\033[0m"
}

add_file() {
        ###
        ###got the message
        ###
        echo "the file you add:"
        echo "======================="
        for file in $@
        do
                #git add $file 
                echo $file
                local file_name=$(echo ${file##*/} | grep "customer_*")
                local SUFFIX=$(echo ${file_name##*.})
                if [ "$SUFFIX" = "h" ]
                then
                        CUSTOMER_FILE=$file
                fi
        done
        CUSTOMER=$(echo ${CUSTOMER_FILE##*_})
        CUSTOMER=$(echo ${CUSTOMER%%.*})
        CUSTOMER=$(echo $CUSTOMER | tr 'a-z' 'A-Z')
       
        ###
        ### check if is Empty of the "git diff customer_xxx"
        ### 
        local customer_diff=$(git diff $CUSTOMER_FILE)
        if Is_Empty $customer_diff
        then
                print_err "ERROR:git diff $CUSTOMER_FILE is Empty!!"
                #echo -e "\033[31m ERROR:git diff $CUSTOMER_FILE is Empty!! \033[0m"
                exit 4
        fi

        ###
        ###get the model_id
        ###must bofore add file
        local SIGN1="("
        local SIGN2="\)"
        MODEL_ID=$(git diff --unified=0 $CUSTOMER_FILE | grep "#elif*");
        MODEL_ID=$(echo ${MODEL_ID##*$SIGN1})
        MODEL_ID=$(echo ${MODEL_ID%%$SIGN2*})
        echo "======================="
        echo "++++++++++++++++++++++++"
        echo "message confirm:"
        echo "customer_xxx:"
        echo $CUSTOMER_FILE
        echo "cutomer:"
        echo $CUSTOMER
        echo "Model_ID: "
        echo $MODEL_ID
        echo "++++++++++++++++++++++++"
        
        ###
        ###add file
        ###
        for file in $@
        do
                git add $file
        done
}



commit_change() {

        if Is_Empty $CUSTOMER || Is_Empty $MODEL_ID
        then
                print_err "CUSTOMER or MODEL_ID is empty"
                exit 2
        fi

        ###
        ###compent the commit msg
        ###
        COMMIT_MSG="[config][$CUSTOMER][$MODEL_ID]add customer config

        [what]add customer config
        [why]none
        [how]none"
        echo "======================================"
        echo "COMMIT_MSG:"
        echo -e "$COMMIT_MSG"
        echo "======================================"
        COMMIT_RESULT=$(git commit -m "$COMMIT_MSG")       
}

do_push(){
        find_git_branch
        local git_branch=$(echo $git_branch | sed "s/(\(.*\)).*/\1/g")
        local local_ver=$(echo $git_branch | grep -Po "\d+.\d+\.\d+")
        if [ "local_ver" != "" ]
        then
                local last_stable_ver=$(cvt-baseline-versions | grep laststable | grep -Po "\d+.\d+\.\d+")
                echo last
                if [ "$last_stable_ver" != "$local_ver" ]
                then
                        echo "你的本地基线版本不是最新基线版本，确认是否继续(Y/N)(默认继续)?"
                fi

        fi
        if git remote -v | grep "tv@git.gz.cvte.cn"
        then
                echo "It's a git"
                PUSH_RESULT=$(git push origin $git_branch)
        else
                echo "Is's not a git"
                PUSH_RESULT=$(git gt-dpush origin $git_branch)
        fi
}

push(){
        PUSH_TIME=$(($PUSH_TIME + 1))
        if [ $PUSH_TIME -gt 5 ]
        then
                print_err "ERROR:PUSH retry time > 5"
                exit 1
        fi
        ###
        ###sync the local code to the newest
        ###
        local git_log=$(git log -1)
        git_log=(${git_log})
        gitsync ${git_log[1]}
        ###
        do_push
        if echo $PUSH_RESULT | grep "your code is no newest, please update first!!!"
        then    
                ###
                ###still not the newest
                ###
                gitsync ${git_log[1]}
                push
        elif echo $PUSH_RESULT | grep "conflict"
        then
                print_err "there is conflict exist, pls handle it"
                exit 5
        fi
}


check_param() {
        if [ $1 -lt 1 ]
        then
                print_err "please use the script with files paramaters"
                echo "Usage: addNewModel <files>"
                exit 3
        fi
}

check_param $#
add_file $@
echo "going to commit......"
sleep 2
commit_change $@
#push


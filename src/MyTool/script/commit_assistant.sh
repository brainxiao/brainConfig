#!/bin/sh 
### this script is used to commit the new model_id
### author:xiaozhitao
### version:1.2.1
### proudly presented by CVTE

### mail 列表的建立：此列表用于pyocs时根据输入的客户名去抓对应的邮箱地址
### 文件名字： .cus_mail
### 文件路径：客户根目录下

PUSH_TIME=0
CUS_MAIL_MSG=0

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

get_mail_address(){
        if [ "$1" == "" ]
        then
                return 1
        fi
        if [ -f $HOME/.cus_mail ]
        then
                #echo "cus_mail config file exist"
                while read line
                do
                        local cus_name=$(echo ${line%% *})
                        if [[ "$cus_name" =~ "$1" ]]
                        then
                                mail_address=$(echo ${line##* } | sed "s/$1 //" | sed "s/ //")
                                CUS_MAIL_MSG=$line
                                return 0
                        fi
                done < /$HOME/.cus_mail
        else
                echo "please add the file: .cus_mail to $HOME"
        fi
        if [ $CUS_MAIL_MSG -eq 0 ]
        then
                print_err "can not find this customer message"
                return 1
        fi
}

add_file() {
        ###
        ###got the message
        ###
        #echo "the file you add:"
        #echo "======================="
        for file in $@
        do
                #git add $file 
                #echo $file
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
        MODEL_ID=$(git diff --unified=0 $CUSTOMER_FILE | grep "IsModelID*");
        MODEL_ID=$(echo ${MODEL_ID##*$SIGN1})
        MODEL_ID=$(echo ${MODEL_ID%%$SIGN2*})
        #echo "======================="
        echo "++++++++++++++++++++++++++++++++++ 信息确认 ++++++++++++++++++++++++++++++"
        echo -n "customer_xxx: "
        print_err $CUSTOMER_FILE
        echo -n "cutomer:      "
        print_err $CUSTOMER
        echo -n "Model_ID:     "
        print_err $MODEL_ID
        echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
        
        ###
        ###add file
        ###
        for file in $@
        do
                if [ "x$file" == "x-n" ]
                then
                        continue
                fi
                git add $file
        done
}

get_model_ID_from_last_commit(){
        local SIGN1="("
        local SIGN2="\)"

        MODEL_ID=$(git show --unified=0 | grep "IsModelID*");
        MODEL_ID=$(echo ${MODEL_ID##*$SIGN1})
        MODEL_ID=$(echo ${MODEL_ID%%$SIGN2*})
    
}



commit_change() {

        if Is_Empty $CUSTOMER || Is_Empty $MODEL_ID
        then
                print_err "CUSTOMER or MODEL_ID is empty"
                exit 2
        fi

        read -ep "除了 add customer config 外你想添加的log内容：" extra_log

        ###
        ###compent the commit msg
        ###
        COMMIT_MSG="[config][$CUSTOMER][$MODEL_ID]add customer config

        [what]add customer config $extra_log
        [why]none
        [how]none"
        echo "======================================"
        echo "COMMIT_MSG:"
        echo -e "$COMMIT_MSG"
        echo "======================================"
        git commit -m "$COMMIT_MSG" 
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
                        read -ep "你的本地基线版本不是最新基线版本，确认是否继续(Y/N)(默认继续)?" PUSH_CODE
                        if [ $PUSH_CODE = "N" ] && [ $PUSH_CODE = "n" ]
                        then
                                echo "exit......"
                                return 1
                        fi
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

stash(){
        read -ep "stash the other change?(Y/N)[Yes for default]:" stash_sign
        if [ "$stash_sign" != "n" ] && [ "$stash_sign" != "N" ]
        then
                stash_result=$(git stash)
                echo -e $stash_result
                if [[ "$stash_result" =~ "No local changes to save" ]]
                then
                        stash_sign="n"
                fi
        fi
}

stash_pop(){
        if [ "$stash_sign" != "n" ] && [ "$stash_sign" != "N" ]
        then
                git stash pop
        fi
}

push(){
        read -ep "Push the code?(Y/N):" PUSH_CODE
        if [ "$PUSH_CODE" != "Y" ] && [ "$PUSH_CODE" != "y" ]
        then
                echo "exit......"
                return 1
        fi
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



time_delay(){
        tput sc
        time=$1
        while [ $time -gt 0 ]
        do
                tput rc
                tput ed
                echo -n "倒数$time秒..."
                sleep 1
                time=$((time - 1))
        done
        echo
}

build(){
        local build_sign
        echo "========================================="
        read -ep "Input if you want to build the software in jenkins(Y/N): "  build_sign
        echo 
        if [ "$build_sign" == "Y" ] || [ "$build_sign" == "y" ]
        then
                cdx customers
                read -ep "输入软件要发送到的客户(N/n 默认不发送)：" mail_cus
                #pwd
                get_mail_address $mail_cus
                echo $mail_address
                if [ $? -ne 0 ] || [ "$mail_cus" == "N" ] || [ "$mail_cus" == "n" ] || [ "$mail_cus"x == ""x ]
                then
                    echo "go into pyocs......"
                    pyocs jenkins $MODEL_ID
                else
                    echo "============================================"
                    echo "============================================"
                    read -ep "输入发送的邮件标题：" mail_title
                    echo "================确认以下信息=================="
                    print_err "客户：$mail_cus"
                    print_err "邮箱：$mail_address"
                    print_err "标题：$mail_title"
                    echo
                    echo
                    #time_delay 5
                    echo "go into pyocs......"
                    pyocs jenkins $MODEL_ID --mail "$mail_address" --mail_title "$mail_title"
                fi
        fi
}

check_param() {
        if [ $1 -lt 2 ]
        then
                print_err "please use the script with files paramaters"
                echo "Usage: addNewModel <files>"
                exit 3
        fi
}

add_new_model_id(){
        local sleep_time=6
        check_param $#
        add_file $@
        echo -n "going to commit"
        while [ $sleep_time -gt 0 ]
        do
                sleep 0.3
                echo  -n "."
                sleep_time=$(( $sleep_time - 1 ))
        done
        echo
        commit_change $@
        stash
        push
        if [ $? -ne 1 ]
        then
            build
        fi
        stash_pop
}

build_lastest_code(){
        get_model_ID_from_last_commit
        echo "===================MODEL ID====================="
        echo
        print_err $MODEL_ID
        echo
        echo "================================================"
        build
}

display_help_msg(){
        echo "=======================help message======================"
        echo "commit_assistant.sh"
        echo
        echo -e "Options:\n"
        echo "  -n <files>                    add your new model ID , commit , push , build"
        echo "  -b                            build the software according to your last commit"
        echo 
}

if [ "$1" == "help" ]
then
        display_help_msg
fi


while getopts "n:bhm:" OPT
do
        case $OPT in
                n)
                        add_new_model_id $@
                        ;;
                b)
                        build_lastest_code
                        ;;
                h)
                        display_help_msg
                        ;;
                m)
                        MODEL_ID=$OPTARG
                        build
                        ;;
        esac
done

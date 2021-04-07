#!/bin/sh 
### usage:使用此脚本来自动产生log，并提交代码，只针对部分FAE简单情况的修改
### 目前支持的:修改LOGO、修改屏参、修改占空比、修改遥控、声音曲线、PQ、按键板
### author:xiaozhitao
### date:2020.04.13
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
get_customer_file(){
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
}

get_model_id(){
        ###
        ###get the model_id
        ###must bofore add file
        model_id_content="null"
        git diff -U20 --output=$HOME/.diff.txt $CUSTOMER_FILE > /dev/null
        while read line
        do
                if echo $line | grep "IsModelID" > /dev/null
                then
                        model_id_content=$line
                fi
                if echo $line | grep "+#define" > /dev/null && [ "$model_id_content" != "null" ]
                then
                        break;
                fi
        done < $HOME/.diff.txt
        #echo $model_id_content
        #model_id_content=$(echo ${model_id_content%%+#define*})
        #model_id_content=$(echo ${model_id_content##*elif})
        local SIGN1="("
        local SIGN2="\)"
        MODEL_ID=$(echo $model_id_content | grep "IsModelID*");
        MODEL_ID=$(echo ${MODEL_ID##*$SIGN1})
        MODEL_ID=$(echo ${MODEL_ID%%$SIGN2*})
}

log_msg_add_content(){
    if [ "$LOG_MSG" == "config" ]
    then
            LOG_MSG="$LOG_MSG $1"
    else
            LOG_MSG="$LOG_MSG,$1"
    fi
}

get_log_msg(){
    LOG_MSG="config"
    local git_diff=$(git diff --unified=0 $CUSTOMER_FILE)
    if echo $git_diff | grep "LOGO" > /dev/null 
    then
            log_msg_add_content "LOGO type"
    fi
    if echo $git_diff | grep "PANEL" > /dev/null
    then
            log_msg_add_content "PANEL type"
    fi
    if echo $git_diff | grep "REF" > /dev/null
    then
            log_msg_add_content "REF value"
    fi
    if echo $git_diff | grep "IR_TYPE" > /dev/null
    then
            log_msg_add_content "IR type"
    fi
    if echo $git_diff | grep "SOUND" > /dev/null
    then
            log_msg_add_content "sound type"
    fi
    if echo $git_diff | grep "PQ" > /dev/null
    then
            log_msg_add_content "PQ type"
    fi
    if echo $git_diff | grep "KEYPAD" > /dev/null
    then
            log_msg_add_content "keypad type"
    fi
    if echo $git_diff | grep "MIRROR" > /dev/null
    then
            log_msg_add_content "mirror"
    fi
    if echo $git_diff | grep "COUNTRY" > /dev/null
    then
            log_msg_add_content "country"
    fi
    if echo $git_diff | grep "LAUNCHER" > /dev/null
    then
            log_msg_add_content "launcher type"
    fi
    if echo $git_diff | grep "OCS" > /dev/null
    then
            log_msg_add_content "OCS number"
    fi
    if echo $git_diff | grep "TUNER" > /dev/null 
    then
            log_msg_add_content "TUNER TYPE"
    fi


   
}
get_log_keyvalue() {
   get_customer_file $@
   get_model_id
   echo "======================="
   echo "++++++++++++++++++++++++"
   echo "message confirm:"
   echo "customer_xxx:"
   echo $CUSTOMER_FILE
   echo -e "\ncutomer:"
   echo $CUSTOMER
   echo -e "\nModel_ID: "
   echo $MODEL_ID
   echo "++++++++++++++++++++++++"
 
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
        COMMIT_MSG="[config][$CUSTOMER][$MODEL_ID]$LOG_MSG

        [what]$LOG_MSG
        [why]none
        [how]none"
        echo "======================================"
        echo "COMMIT_MSG:"
        echo -e "$COMMIT_MSG"
        echo "======================================"
        git commit -m "$COMMIT_MSG"
}
add_file(){ 
        ###
        ###add file
        ###
        for file in $@
        do
                git add $file
        done
}
check_param() {
        if [ $1 -lt 1 ]
        then
                print_err "please use the script with files paramaters"
                echo "Usage: fae_auto_commit <files>"
                exit 3
        fi
}
check_param $#
print_err "请务必自行检查生成的LOG是否正确，敬畏代码~~"
get_log_keyvalue $@
get_log_msg
add_file $@
commit_change

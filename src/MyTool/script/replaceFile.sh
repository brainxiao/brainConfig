#!/bin/bash
### author:xiaozhitao
###
### this script is used to replace a file ,
### such as a APK ,you can use this script in 
### 658,358
###
### Usage: you need to get the root mod firstly,
### then enter your source file in the first paramter
### enter your dst file in the second paramter
#########################################################
function help_func {
    echo "Usage:"
    echo "myscript [-h] [-v] [-f <filename>] [-o <filename>]"
    exit -1
}
function replace {
    echo "替换文件：$SOURCE"
    echo "替换到：$DST"
    owner=0
    group=0
    other=0
    ### 检查目标文件是否已经存在，
    ### 如果存在的话就要保证权限一样
    if [ ! -e $DST ]
    then
        echo "File: $DST no exist,copy directly"
        cp $SOURCE $DST
    else
        echo "$DST exist,check mod then replace"
        LS=$(ls -al $DST)
        LS_array=($LS)
        MOD=${LS_array[0]}#拿到权限的字符形式

        i=1;j=1
        for(( ; i<10 ; i++ , j++))#将权限的而字符形式换算成数值形式
        do
            tmp=${MOD:$i:1}
            if [ $i -eq 4 ] || [ $i -eq 7 ]
            then
                j=1
            fi

            if [ $i -lt 4 ]
            then
                if [[ $tmp != '-' ]]
                then
                    mi=$((3-$j))
                    owner=$(($owner + 2 ** $mi))
                fi
            elif [ $i -ge 4 ] && [ $i -lt 7 ] 
            then
                if [[ $tmp != '-' ]]
                then
                    mi=$((3-$j))
                    group=$(($group + 2 ** $mi))
                fi
            elif [ $i -ge 7 ]
            then
                if [[ $tmp != '-' ]]
                then
                    mi=$((3-$j))
                    other=$(($other + 2 ** $mi))
                fi
            fi
        done
        mod_num=$owner$group$other
        echo $mod_num
        cp $SOURCE $DST
        chmod $mod_num $DST
    fi
}

while getopts :hs:vd: OPT
do
    case $OPT in
        s) SOURCE=$OPTARG
            ;;
        d) DST=$OPTARG
            ;;
        h) help_func
            exit 0
            ;;
        v) echo "version 1.0"
            exit 0
            ;;
        ?) echo "paramter error "
            exit 1
            ;;
    esac
done

replace

#!/bin/sh
### 用于自动添加客户配置,包括customer仓库和cps仓库
### 使用方法：在代码根目录下运行此脚本，以客户ID作为参数
### 使用不了原因分析：是否有关键字："MODEL_ID error" 和 "CVT_DEF_KEYPAD_TYPE no define"

### 1：open debug msg
### 0: close debug msg
dbg=0
############标志定义#############
model_ID_ELSE_SIGN="MODEL_ID error"
keypad_ELSE_SIGN="CVT_DEF_KEYPAD_TYPE no define"
#######################################################

dbg_echo(){
    if [ $dbg -eq 1 ]; then
        echo $@
    fi
}

print_err() {
        echo -e "\033[31m$@\033[0m"
}

check_contents(){
    if cat $1 | grep "$2" > /dev/null
    then
        return 0
    else
        return 1
    fi
}

analyze_cus(){
    cus_ID=$1
    cus_name_UP=$(echo $cus_ID | tr 'a-z' 'A-Z')
    #cus_name=$(echo ${cus_ID##*_})
    cus_name=$(echo $cus_name_UP | sed -n 's/CUSTOMER_//p')
    cus_name_LOW=$(echo $cus_name | tr 'A-Z' 'a-z')
    cus_name_UP=$(echo $cus_name | tr 'a-z' 'A-Z')
    cus_h_file=customers/customer/customer_$cus_name_LOW/customer_$cus_name_LOW.h
    cus_xml_file=cps_autobuild/proj/config/cps_support_customers_map.xml

    text1="#define CPS_MODEL_ID_DEFAULT                      4998//only for cps auto build use"
    text2="\/\/ cps framework must include before \"#define MODEL_ID\"\n\/\/ cps_id_define.h contain MODEL_ID,  KEYPAD\n#include \"..\/..\/..\/cps_autobuild\/customers\/customer/customer_$cus_name_LOW\/cps_customer_id_mode.h\"\n#include \"..\/..\/..\/cps_autobuild\/customers\/customer\/customer_$cus_name_LOW\/cps_customer_id_keypad.h\"\n"
    text3="#if ( IsModelID(CPS_MODEL_ID_DEFAULT) )\n"
    text4="\/\/ cps framework must include\n#include \"..\/..\/..\/cps_autobuild\/customers\/customer\/customer_$cus_name_LOW\/cps_customer_order.h\""
    text5="\/\/ cps framework must include\n#include \"..\/..\/..\/cps_autobuild\/customers\/customer\/customer_$cus_name_LOW\/cps_customer_keypad_select.h\""
    text6="             <customerid name=\"CUSTOMER_$cus_name_UP\">\n                <path>customers\/customer\/customer_$cus_name_LOW\/customer_$cus_name_LOW.h<\/path>\n            <\/customerid>"
}

#检查是否在项目根目录下
check_root(){
        if [ -d customers ] && [ -d cps_autobuild ]
        then
                echo "根目录检查OK..."
        else
                echo "当前执行目录不在项目根目录，退出中..."
                exit
        fi
}

#检查是否已经定义该客户
check_cus(){
        if check_contents $cus_h_file "$model_ID_ELSE_SIGN" && check_contents $cus_h_file "$keypad_ELSE_SIGN" ; then
                dbg_echo "===========标志检查OK============"
        else
                print_err "客户: $cus_name_UP 检查标志FAIL，可以进入脚本替换相关标志"
                exit
        fi

        if [ -d customers/customer/customer_$cus_name_LOW ] && check_contents customers/customer/customer.h CUSTOMER_$cus_name_UP
        then
                echo "客户检查OK"
        else
                print_err "客户: $cus_name_UP 检查FAIL，请确认客户是否添加完善"
                exit
        fi
}

#处理客户头文件
add_msg_to_customer(){
        line_num1=$(cat -n $cus_h_file | sed -n '/#define.*1/p' | sed -n '1p' | sed -n 's/#define.*//p' | sed -n 's/ *//p')
        dbg_echo $line_num1
        line_num2=$(cat -n $cus_h_file | sed -n '/MODEL_ID/p' | sed -n '1p' | sed -n 's/#define.*//p' | sed -n 's/ *//p')
        dbg_echo $line_num2
        line_num2=$(($line_num2 + 1))

        sed -i "$line_num1 i $text1" $cus_h_file
        sed -i "$line_num2 i $text2" $cus_h_file

        line_num3=$(cat -n $cus_h_file | sed -n '/IsModelID/p' | sed -n '1p' | sed -n 's/#.*//p' | sed -n 's/ *//p')
        dbg_echo $line_num3
        sed -i "$line_num3 s/#if/#elif/" $cus_h_file
        sed -i "$line_num3 i $text3" $cus_h_file

        line_num4=$(cat -n $cus_h_file | sed -n "/$model_ID_ELSE_SIGN/p" | sed -n '1p' | sed -n 's/#.*//p' | sed -n 's/ *//p')
        dbg_echo $line_num4
        sed -i "$line_num4 d" $cus_h_file
        sed -i "$line_num4 i $text4" $cus_h_file

        line_num5=$(cat -n $cus_h_file | sed -n "/$keypad_ELSE_SIGN/p" | sed -n '1p' | sed -n 's/#.*//p' | sed -n 's/ *//p')
        dbg_echo $line_num5
        sed -i "$line_num5 d" $cus_h_file
        sed -i "$line_num5 i $text5" $cus_h_file

        echo "处理客户头文件结束..."
}

#处理cps仓内容
add_cus_in_cps(){
    #拷贝目录
    cp -rf cps_autobuild/customers/customer/aa_demo_customer cps_autobuild/customers/customer/customer_$cus_name_LOW
    #xml中插入客户目录
    line_num6=$(cat -n $cus_xml_file | sed -n '/customerid/p' | sed -n '$p' | sed -n 's/<.*//p' | sed -n 's/ *//p')
    dbg_echo $line_num6
    sed -i "$line_num6 a $text6" $cus_xml_file
    line_num6=$(($line_num6 + 1))
    sed -i "$line_num6 s/<customer/            <customer/" $cus_xml_file
    echo "处理CPS仓库结束..."
}


add_cus(){
    echo "处理客户：$1"
    analyze_cus $1
    check_cus
    add_msg_to_customer
    add_cus_in_cps
    echo
}

check_result(){
    echo ">>>>>>>>>>检查结果<<<<<<<<<<"
    local root_folder=$(pwd)
    echo $root_folder
    ./cps_autobuild/test_cps_cmd_check_customer.sh $root_folder CUSTOMER_$cus_name_UP
}

print_help_msg(){
    echo -e "Usage:\n\t-h\t显示帮助信息\n\t-c\t后接<CUSTOMER_ID><CUSTOMER_ID>...为多个客户添加CPS支持\n\t\teg. cps_cmd_add_cus.sh -c CUSTOMER_PANDA CUSTOMER_JINDI"
}

while getopts "c:h" OPT
do
    case $OPT in 
        h)
            print_help_msg
            ;;
        c)
            check_root
            for cus in $@
            do
                if [ $cus == "-c" ]
                then
                    continue
                fi
                add_cus $cus
                check_result
            done
            ;;

        *)
            print_help_msg
            ;;
    esac
done

#!/usr/bin/expect 
###author:xiaozhitao
###
###
set timeout 100
set test_type [lindex $argv 0]
set sw_msg [lindex $argv 1]
set make_bin [lindex $argv 2]
set model_id [lindex $argv 3]
spawn /usr/local/bin/pyocs jenkins $model_id
expect {
"输入测试类型" {send "$test_type\r";exp_continue}
"输入软件备注信息" {send "$sw_msg\r";exp_continue}
"请确认是否做BIN" {send "$make_bin\r"}
}

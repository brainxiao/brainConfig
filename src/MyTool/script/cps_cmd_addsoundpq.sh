# !/bin/sh

# demo
#  ./cps_autobuild/test_cps_cmd_add_sound.sh localcode_fullpath  customerID (CUSOMER_SAMPLE_SELF)
#
#  eg:    ./cps_autobuild/test_cps_cmd_add_sound.sh /home/chenming/workcodes/628alios1Gfae  CUSOMER_SAMPLE_SELF

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

cdx customers
cd ..
CODEDIR=$(pwd)
pwd
cd cps_autobuild

CUSTOMERID=$3
SHELLENTRY=$CODEDIR/cps_autobuild/cps_AutoCompile

if [ ! -d $CODEDIR ] ; then
   echo "err: not find code dir $CODEDIR"
   exit 1
fi

if [ ! -f $SHELLENTRY ]; then
   echo "err: not find file cps_AutoCompile $CODEDIR"
   exit 1
fi

BASEOUTDIR=$CODEDIR/xx_test_cps_cmd 
PARAPATH=$BASEOUTDIR/para.txt
RETPATH=$BASEOUTDIR/zzzret.txt
RECORDPATH=$BASEOUTDIR/cpsrecord.txt
OUTDIR=$BASEOUTDIR/outdir
if [ -d $OUTDIR ]; then
    rm -rf $OUTDIR 
fi
mkdir -p $OUTDIR 

CMD=getInterface
echo "command:${CMD}" > $PARAPATH
$SHELLENTRY $CMD $CODEDIR $PARAPATH $RETPATH

CMD=getCustomerXH
echo "customer:${CUSTOMERID}" > $PARAPATH
echo "command:getCustomerXH" >> $PARAPATH
RETPATH=$OUTDIR/defaultret.txt
rm -f $RETPATH
customerxh="not_find_customerxh"
$SHELLENTRY $CMD $CODEDIR $PARAPATH $RETPATH
if [ -f $RETPATH ]; then
    customerxh=$(grep "^getCustomerXH:" $RETPATH | cut -d":" -f2 )
fi

## 配置参数文件



while getopts "p:s:" OPT
do
    case $OPT in
            p)
                    CMD=edit_addDataCPq
                    RES=$2
                    MACRO=ID_PQ_CVTE_PB803_TEST11_CPS
                    echo "command:${CMD}" > $PARAPATH
                    echo "enumname:${MACRO}" >> $PARAPATH
                    echo "resfilepath:${RES}" >> $PARAPATH
                    echo "customerXH:$customerxh" >> $PARAPATH
                    echo "recordfile:$RECORDPATH" >> $PARAPATH
                    $SHELLENTRY $CMD $CODEDIR $PARAPATH $RETPATH
                    ;;
            s)
                    CMD=edit_addDataCSound
                    RES=$2
                    MACRO=ID_SOUND_CVTE_PB803_TEST11_CPS
                    echo "command:${CMD}" > $PARAPATH
                    echo "enumname:${MACRO}" >> $PARAPATH
                    echo "resfilepath:${RES}" >> $PARAPATH
                    echo "customerXH:$customerxh" >> $PARAPATH
                    echo "recordfile:$RECORDPATH" >> $PARAPATH
                    $SHELLENTRY $CMD $CODEDIR $PARAPATH $RETPATH
                    ;;
            ?)
                    echo "未使用任何选项"
    esac
done

#!/bin/sh 
### author:brain
### date:2019.09.25
### run this script to config your home
#######################################
#######################################
VERSION=1.0.0
HOME_DIR=$HOME
BASHRC=${HOME_DIR}/.bashrc 
BIN=${HOME_DIR}/bin
MYTOOL_DIR=${HOME_DIR}/MyTool
VIMRC=${HOME_DIR}/.vimrc
export PATH=$(pwd):$PATH
function makeln {
        echo "making link..."
        if [ ! -e $BIN ]
        then
                mkdir $BIN
        fi 
        for file in $(ls ${MYTOOL_DIR}/script)
        do
                local FILENAME=${file%.*}
                if [ ! -e ${BIN}/${FILENAME} ]
                then
                    ln -s ${MYTOOL_DIR}/script/${file} ${BIN}/${FILENAME}
                    echo "make link ${BIN}/${FILENAME}"
                fi
        done
        echo "make link done"
}
function showdiff {
        if [ -e $2 ]
        then
                diff $1 $2
        fi
}
function config { 
       echo "========config home======="
       echo "git >>>>>>>>>>>>>> Home"
       showdiff src/.bashrc $BASHRC
       showdiff src/.vimrc $VIMRC
       showdiff src/MyTool/ $HOME_DIR/MyTool
       cat src/.bashrc > $BASHRC
       cat src/.vimrc > $VIMRC
       cp -rf src/MyTool/ $HOME_DIR
       makeln
       echo "config done"
}
function sync {
        echo "========sync home========"
        echo "Home >>>>>>>>>>>>>> git"
        cat $BASHRC > src/.bashrc 
        cat $VIMRC > src/.vimrc 
        cp -rf $MYTOOL_DIR src/ 
        echo "sync done"
}
function help {
        echo "config.sh edit by Brain.version $VERSION"
        echo "-c : overwrite the git's file to the home"
        echo "     git >>>>>>>>>>>>> your home"
        echo "-s : sync your home's file to the dir"
        echo "     your home >>>>>>>> git"
        echo "-m : generic the link to MyTool/script in ~/bin"
        echo "-h : print help"
}
while getopts :hcsm OPT
do
    case $OPT in
            h)
                    help
                    ;;
            c)
                    config
                    ;;
            m)
                    makeln
                    ;;
            s)
                    sync
                    ;;
            ?)
                    help
                    ;;
            *)
                    help
                    ;;
    esac
done

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
#VIM_DIR=${HOME_DIR}/.vim 
VIM_MRU=${HOME_DIR}/.vim_mru_files
export PATH=$(pwd):$PATH
function makeln {
        echo "making link..."
        if [ ! -e $BIN ]
        then
                mkdir $BIN
        fi 
        for file in $(ls ${MYTOOL_DIR}/script)
        do
                #echo $file
                local FILENAME=${file%.*}
                #echo $FILENAME
                if [ ! -e ${BIN}/${FILENAME} ]
                then
                    ln -s ${MYTOOL_DIR}/script/${file} ${BIN}/${FILENAME}
                    echo "make link ${BIN}/${FILENAME}"
                fi
        done
        echo "make link done"
}
function config { 
       echo "========config home======="
       echo "git >>>>>>>>>>>>>> Home"
       cat src/.bashrc > $BASHRC
       cat src/.vimrc > $VIMRC
       #cat src/.vim_mru_files > $VIM_MRU
       #cp -rf src/bin/ $BIN
       cp -rf src/MyTool/ $HOME_DIR
       #cp -rf src/.vim/ $HOME_DIR
       makeln
       echo "sync done"
}
function sync {
        echo "========sync home========"
        echo "Home >>>>>>>>>>>>>> git"
        cat $BASHRC > src/.bashrc 
        cat $VIMRC > src/.vimrc 
        #cat $VIM_MRU > src/.vim_mru_files 
        cp -rf $MYTOOL_DIR src/ 
        #cp -rf $VIM_DIR src/.vim/ 
        #cp -rf $BIN > 
        echo "sync done"
}
function help {
        echo "config.sh edit by Brain.version $VERSION"
        echo "-c : overwrite the git's file to the home"
        echo "-s : sync your home's file to the dir"
        echo "-m : generic the link to MyTool/script"
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

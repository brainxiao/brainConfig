#!/bin/bash
###
###
###
### author: xiaozhitao
### date: 2019.08.05
### descrition: for animation to delete some picture,
### because the picture too many will make some prlblem
### usage: the first param is your input dir , the second param is the output dir
### eg.   ./deletePicForanimation part0 part1

dir_path_in=$1
dir_path_out=$2
if [ ! -d $dir_path_in ] || [ ! -d $dir_path_out ]
then
    echo "error : $1 or $2 is not a directory -_-||"
    echo "exiting..."
    exit 1
fi
tmp_num_1=0
tmp_num_2=0
for pic in $dir_path_in/*
do
    echo $pic
    if (( $tmp_num_1 % 2 == 0 ))
    then
        #rm $pic
        #skip it
        echo "odd"
    else
        PIC_NAME=$(printf "%03d" $tmp_num_2)
        cp $pic ${dir_path_out}/${PIC_NAME}.jpg
        tmp_num_2=$[ $tmp_num_2 + 1 ]
    fi
    tmp_num_1=$[ $tmp_num_1 + 1 ]
    #
    #if (( $tmp_num % 2 != 0 ))
    #then
    #    tmp_num=$tmp_num + 1
    #fi
done
    

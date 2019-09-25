#/bin/sh
### author:xiaozhitao
### date:2019/09/16
### this script is used to check the code you have right

echo "checking the gerrit : "
gerrit_ls_projects
echo "checking the not gerrit : "
echo "please wait..."
ssh tv@git.gz.cvte.cn info
exit 0

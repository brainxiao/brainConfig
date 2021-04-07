#!/bin/bash
export PASSWORD="cvte2021"
 
./vscode-server/bin/code-server --port 8888 --host 0.0.0.0 --auth password --cert=/hdd1/xiaozhitao/certs/MyCertificate.crt --cert-key=/hdd1/xiaozhitao/certs/MyKey.key > vscode-server/log.txt

#!/bin/bash

idx=6
ssh=4400
psql=4500
web=8050

qemu-system-x86_64 \
-drive file=pydeb12.qcow2,format=qcow2 \
-m 2G -net nic \
-net user,hostfwd=tcp::$(($ssh + $idx))-:22,hostfwd=tcp::$(($web + $idx))-:80 \
-display none -daemonize

#-net user,hostfwd=tcp::$(($web+ $idx))-:80 \
# portfwd=tcp::host-:client
# 22 for ssh; 80 for web; 5432 for postgresql

until nc -z localhost $(($ssh + $idx)); do sleep 1; done
ssh -p $(($ssh + $idx)) user@localhost
#password for user is 1234u


#!/bin/bash

cat /usr/local/etc/haproxy.cfg | grep server[0-9] | awk '{ print $2,"--->", $3}'

echo "show stat" | socat unix-connect:/tmp/admin.sock stdio | grep server[0-9] | awk -F "," '{ print $1," -> ",$2, " Status: ", $18 }'

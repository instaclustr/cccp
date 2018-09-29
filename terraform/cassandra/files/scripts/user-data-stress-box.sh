#!/usr/bin/env bash
set -x

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

systemctl stop cassandra

echo ${nodelist} | tr "," "\n" >> /home/admin/stress/nodelist.txt
find /home/admin/stress -type f -name 'stressspec*' -exec sed -i "s/{dc}/${dc_name}/g" {} \;
find /home/admin/stress -type f -name 'stressspec*' -exec sed -i "s/{numnodes}/${num_nodes}/g" {} \;
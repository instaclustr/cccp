#!/usr/bin/env bash
set -x

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

instance=`wget -q -O - http://169.254.169.254/latest/meta-data/instance-id`
az=`wget -q -O - http://169.254.169.254/latest/meta-data/placement/availability-zone`
region=`echo $az | sed 's/[a-z]$//'`

# TODO: Actually have user data query for the IP that is attached to it/one user data per AZ
sleep 60 #Dodgy hack for the moment to stop ip from misleadingly getting the default ipv4. (See the README)

ip=`wget -q -O - http://169.254.169.254/latest/meta-data/public-ipv4`
privateip=`wget -q -O - http://169.254.169.254/latest/meta-data/local-ipv4`
while [ -z $ip ]; do
    ip=`wget -q -O - http://169.254.169.254/latest/meta-data/public-ipv4`
    echo "Waiting for EIP to be attached..."
    sleep 5
done

sed -i "s/127.0.1.1.*//g" "/etc/hosts"
sed -i "s/.*update_etc_hosts.*//g" "/etc/cloud/cloud.cfg"

while [ -z `ls /sys/block | grep xvdf` ]; do
    echo "Waiting for volume to be attached..."
    sleep 5
done

formatted=`file -s /dev/xvdf | cut -d ":" -f2`
if [ $formatted == "data" ]; then
    mkfs -t ext4 /dev/xvdf
fi
mkdir -p /cassandra
mount /dev/xvdf /cassandra
echo "/dev/xvdf /cassandra ext4 noatime,nodiratime,barrier=0" >> /etc/fstab

chown -R cassandra:cassandra /cassandra
chmod -R a+x /cassandra

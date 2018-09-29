#!/usr/bin/env bash
set -x

#exec > >(tee /var/log/install_cassandra.log|logger -t install_cassandra -s 2>/dev/console) 2>&1

# If git repo is provided, check it out
if [[ "x${repo}" != "x" && "x${branch}" != "x" ]];
then
    git clone ${repo} cassandra
    cd cassandra && git checkout ${branch}
    mv /tmp/cassandra-dpkg.sh /home/admin/cassandra/
    chmod +x /home/admin/cassandra/cassandra-dpkg.sh
fi

# If should install from repo, install
if [[ "${install_repo}" == "yes" ]]; then
    cd /home/admin/cassandra && ./cassandra-dpkg.sh
# If shouldn't install from repo, install from debian
else
    sudo mv /tmp/etc/apt/sources.list.d/cassandra.sources.list /etc/apt/sources.list.d/cassandra.sources.list
    curl https://www.apache.org/dist/cassandra/KEYS | sudo apt-key add - && sudo apt-get update
    sudo apt-get install cassandra
fi

# Move the configs into the right spots
if [[ -d /tmp/etc/cassandra ]]; then
    [ -d /etc/cassandra ] || sudo mkdir -p /etc/cassandra
    sudo systemctl stop cassandra
    sudo mv /tmp/etc/cassandra/* /etc/cassandra/
    sudo mv /tmp/etc/systemd/system/cassandra* /etc/systemd/system/
fi

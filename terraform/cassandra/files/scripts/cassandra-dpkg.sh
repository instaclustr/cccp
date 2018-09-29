#!/usr/bin/env bash

set -eux

function build_and_install_cassandra {
    version=$(grep "name=\"base.version\"" build.xml | sed -e "s|/>||" | awk '{print $3}')
    eval local ${version}

    dch --distribution unstable --package "cassandra" -v ${value} "Cassandra Test" -b
    dpkg-buildpackage -uc -us
    sudo dpkg -i ../cassandra_${value}_all.deb
}

build_and_install_cassandra
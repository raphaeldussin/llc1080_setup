#!/bin/bash
usage() {
    cat <<EOM
    Usage:
    $(basename $0) datafile parameter_name

EOM
    exit 0
}

datafile=$1
param=$2

sed -n "s/.$param.*= *\(.*\),/\1/Ip" < $datafile


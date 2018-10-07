#!/bin/bash
#
# Usage: bash findport.sh 3000 100
#
if [[ -z "$1" || -z "$2" ]]; then
  echo "Usage: $0 <base_port> <increment>"
  exit 1
fi


BASE=$1
INCREMENT=$2

port=$BASE
isfree=$(cat used_ports | grep $port)

while [[ -n "$isfree" ]]; do
  port=$[port+INCREMENT]
  isfree=$(cat used_ports | grep $port)
done

echo "$port"
exit
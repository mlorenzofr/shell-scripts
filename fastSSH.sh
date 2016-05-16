#!/bin/bash

try=0

while [ ${try} -lt 4 ]; do
	if [ ${try} -eq 2 ]; then
		options="-o PubkeyAuthentication=no"
    elif [ ${try} -eq 3 ]; then
		options="-o PubkeyAuthentication=no -l root"
	fi
	ssh -X ${options} $(basename ${0}) $@ && break
    try=$((${try}+1))
done

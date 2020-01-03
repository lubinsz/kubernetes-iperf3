#!/usr/bin/env bash
set -eu

CLIENTS=$(kubectl get pods -l app=iperf-client -o name | cut -d'/' -f2)

for POD in ${CLIENTS}; do
    until $(kubectl get pod ${POD} -o jsonpath='{.status.containerStatuses[0].ready}'); do
        echo "Waiting for ${POD} to start..."
        sleep 5
    done
    HOST=$(kubectl get pod ${POD} -o jsonpath='{.status.hostIP}')
    kubectl exec -it ${POD} -- iperf -c iperf-server -P 3 -T "Client on ${HOST}" $@
    echo
done

#!/bin/bash -ve

export KUBECONFIG=$K8S_CONFIG # get access configs for the cluster
export K8S_NAMESPACE=$(echo ${CI_JOB_NAME}-${CI_JOB_ID}-${CI_PIPELINE_ID} | tr '_' '-' | tr '[:upper:]' '[:lower:]')

kubectl create namespace $K8S_NAMESPACE
./install.sh $K8S_NAMESPACE

kubectl get pods --namespace=$K8S_NAMESPACE --no-headers
sleep 5 # give some time to run the install

count=0
while [[ $count -le 120 ]] && [[ $(kubectl get pods --namespace=$K8S_NAMESPACE --no-headers | grep -v "Running") ]]; do

    if [[ $(($count%10)) == 0 ]]; then
        echo "Current situation of pods:"
        kubectl get pods --namespace=$K8S_NAMESPACE
        echo "Wait for complete deployment... $count"
    fi
	(( count++ ))
	sleep 1

done

[[ $count -le 120 ]]

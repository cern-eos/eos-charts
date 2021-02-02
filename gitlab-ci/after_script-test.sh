#!/bin/bash -ve

export KUBECONFIG=$K8S_CONFIG # get access configs for the cluster
export K8S_NAMESPACE=$(echo ${CI_JOB_NAME}-${CI_JOB_ID}-${CI_PIPELINE_ID} | tr '_' '-' | tr '[:upper:]' '[:lower:]')

./gitlab-ci/collect_logs.sh $K8S_NAMESPACE eos-logs-${CI_JOB_ID}

./uninstall.sh $K8S_NAMESPACE
kubectl delete namespace $K8S_NAMESPACE


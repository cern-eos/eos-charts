#! /bin/bash

# **************************************************************************** #
#                                  Utilities                                   #
# **************************************************************************** #

function usage () {
  filename=$(basename $0)
  echo "Usage: $filename <namespace> <logdir>"
  echo "  Collect logs from EOS kubernetes pods."
  echo "  For logs to be collected, the pod must start with \"eos\" and have the following keywords: mgm mq fst qdb cli"
  echo "       namespace  : name of the k8s namespace (DNS-1123 label)"
  echo "       logdir     : location where logs should be placed"
  echo ""

  exit 1
}

# **************************************************************************** #
#                                  Entrypoint                                  #
# **************************************************************************** #

# Arguments parsing
if [[ "$#" -ne 2 ]]; then
  usage
fi

K8S_NAMESPACE="$1"
if [[ ! ${K8S_NAMESPACE} =~ ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$ ]]; then
  echo "Namespace label not DNS-1123 compatible!"
  exit 1
fi

# Create logs directory
logdir="$2"
mkdir -p ${logdir}
if [ ! -d ${logdir} ] ; then
  echo "Failed to create directory: ${logdir}"
  exit 1
fi

# Get pod names for MQ/MGM/FST/QDB EOS services
EOSMQ=$(kubectl get pods --namespace $K8S_NAMESPACE | grep "^eos" | grep mq | sort | cut -d" " -f1)
EOSMGM=($(kubectl get pods --namespace $K8S_NAMESPACE | grep "^eos" | grep mgm | sort | cut -d" " -f1))
EOSFST=($(kubectl get pods --namespace $K8S_NAMESPACE | grep "^eos" | grep fst | sort | cut -d" " -f1))
EOSQUARKDB=($(kubectl get pods --namespace $K8S_NAMESPACE | grep "^eos" | grep qdb | sort | cut -d" " -f1))

# Get optional pod names for client services
EOSCLIENT=($(kubectl get pods --namespace $K8S_NAMESPACE | grep "^eos" | grep client | sort | cut -d" " -f1))

# ******************************************************************************
# Collect logs
# ******************************************************************************

### Note: 
### Absolute paths given to 'kubectl cp' will generate the following warning message:
### "tar: Remove leading '/' from member names"
### The ending "grep -v" is esthetic filtering of that warning message

# Collect MQ logs
kubectl cp ${K8S_NAMESPACE}/${EOSMQ}:/var/log/eos/mq/xrdlog.mq ${logdir}/${EOSMQ}.log 2>&1 | grep -v "tar: Removing leading"

# Collect MGM logs
count=0
for container in "${EOSMGM[@]}"; do
  count=$((count + 1))
  kubectl cp ${K8S_NAMESPACE}/${container}:/var/log/eos/mgm${count}/xrdlog.mgm ${logdir}/${container}.log 2>&1 | grep -v "tar: Removing leading"
done

# Collect FST logs
count=0
for container in "${EOSFST[@]}"; do
  count=$((count + 1))
  kubectl cp ${K8S_NAMESPACE}/${container}:/var/log/eos/fst${count}/xrdlog.fst ${logdir}/${container}.log 2>&1 | grep -v "tar: Removing leading"
done

# Collect QDB logs
count=0
for container in "${EOSQUARKDB[@]}"; do
  count=$((count + 1))
  kubectl cp ${K8S_NAMESPACE}/${container}:/var/log/eos/qdb${count}/xrdlog.qdb ${logdir}/${container}.log 2>&1 | grep -v "tar: Removing leading"
done

# Collect client logs
for container in "${EOSCLIENT[@]}"; do
  kubectl cp ${K8S_NAMESPACE}/${container}:/var/log/eos/fuse/ ${logdir}/${container}-fuse/ 2>&1 | grep -v "tar: Removing leading"
  kubectl cp ${K8S_NAMESPACE}/${container}:/var/log/eos/fusex/ ${logdir}/${container}-fusex/ 2>&1 | grep -v "tar: Removing leading"
done

# List destination directory
ls -l ${logdir}

exit 0


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

function get_pods() {
  kubectl get pods --namespace=${NAMESPACE} --no-headers -o custom-columns=":metadata.name"
}

# **************************************************************************** #
#                                  Entrypoint                                  #
# **************************************************************************** #

# Arguments parsing
if [[ "$#" -ne 2 ]]; then
  usage
fi

NAMESPACE="$1"
if [[ ! ${NAMESPACE} =~ ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$ ]]; then
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

# Get pod names for MQ/MGM/FST EOS services
EOSMQ=$(get_pods | grep "^eos" | grep mq)
EOSMGM=($(get_pods | grep "^eos" | grep mgm | sort))
EOSFST=($(get_pods | grep "^eos" | grep fst | sort))

# Get optional pod names for QDB and client services
EOSQUARKDB=$(get_pods | grep "^eos" | grep qdb)
EOSCLIENT=($(get_pods | grep "^eos" | grep cli))

# ******************************************************************************
# Collect logs
# ******************************************************************************

### Note: 
### Absolute paths given to 'kubectl cp' will generate the following warning message:
### "tar: Remove leading '/' from member names"
### The ending "grep -v" is esthetic filtering of that warning message

# Collect MQ logs
kubectl cp ${NAMESPACE}/${EOSMQ}:/var/log/eos/mq/xrdlog.mq ${logdir}/${EOSMQ%%-deployment*}.log 2>&1 | grep -v "tar: Removing leading"

# Collect MGM logs
for container in "${EOSMGM[@]}"; do
  kubectl cp ${NAMESPACE}/${container}:/var/log/eos/mgm/xrdlog.mgm ${logdir}/${container%%-deployment*}.log 2>&1 | grep -v "tar: Removing leading"
done

# Collect FST logs
count=0
for container in "${EOSFST[@]}"; do
  count=$((count + 1))
  kubectl cp ${NAMESPACE}/${container}:/var/log/eos/fst${count}/xrdlog.fst ${logdir}/${container%%-deployment*}.log 2>&1 | grep -v "tar: Removing leading"
done

# Collect QDB logs
if [[ ! -z $EOSQUARKDB ]]; then
  kubectl cp ${NAMESPACE}/${EOSQUARKDB}:/var/log/eos/qdb/xrdlog.qdb ${logdir}/${EOSQUARKDB%%-deployment*}.log 2>&1 | grep -v "tar: Removing leading"
fi

# Collect client logs
for client in "${EOSCLIENT[@]}"; do
  kubectl cp ${NAMESPACE}/${client}:/var/log/eos/fuse/ ${logdir}/${client%%-deployment*}-fuse/ 2>&1 | grep -v "tar: Removing leading"
  kubectl cp ${NAMESPACE}/${client}:/var/log/eos/fusex/ ${logdir}/${client%%-deployment*}-fusex/ 2>&1 | grep -v "tar: Removing leading"
done

# List destination directory
ls -l ${logdir}

exit 0


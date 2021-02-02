#!/bin/bash

helm install --namespace ${1:-"default"} eos-qdb qdb/
helm install --namespace ${1:-"default"} eos-mq  mq/
helm install --namespace ${1:-"default"} eos-mgm mgm/
helm install --namespace ${1:-"default"} eos-fst fst/
# optional
helm install --namespace ${1:-"default"} eos-client client/


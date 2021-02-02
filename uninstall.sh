#!/bin/bash

helm uninstall --namespace ${1:-"default"} eos-qdb
helm uninstall --namespace ${1:-"default"} eos-mq
helm uninstall --namespace ${1:-"default"} eos-mgm
helm uninstall --namespace ${1:-"default"} eos-fst

helm uninstall --namespace ${1:-"default"} eos-client

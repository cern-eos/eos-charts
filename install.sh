#!/bin/bash

helm install eos-qdb qdb/
helm install eos-mq  mq/
helm install eos-mgm mgm/
helm install eos-fst fst/
# optional
helm install eos-client client/


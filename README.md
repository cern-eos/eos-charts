# eos-charts

Helm Charts for EOS deployment on Kubernetes

### How to
1. Start pods for the eos components
```
helm install eos-qdb /qdb
helm install eos-mq  /mq
helm install eos-mgm /mgm
helm install eos-fst /fst
```

The name (`eos-qdb`, `eos-mgm`, ...) passed to Helm is relevant as it will be reflected in the DNS name of the component.

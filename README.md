# eos-charts

Helm Charts for EOS deployment on Kubernetes

### How to
1. Start pods for the eos components
```
helm install eos-qdb <chart_location>	(chart_location e.g.: eos-charts/qdb)
helm install eos-mq  <chart_location>
helm install eos-mgm <chart_location>
helm install eos-fst <chart_location>
```

The name (`eos-qdb`, `eos-mgm`, ...) passed to Helm is relevant as it will be reflected in the DNS name of the component.

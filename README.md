# eos-charts

Helm Charts for EOS deployment on Kubernetes

### How to install EOS Helm charts

To install EOS using helm charts:

```
helm install eos eos/server
```

Note: Currently the deployment fails without the `eos.keytab` secret. In order to deploy the required secret run:

```
kubectl create secret generic eos-sss-keytab --from-file=files/eos.keytab
```

The eos.keytab can be found [here](https://github.com/sciencebox/charts/blob/master/sciencebox/files/eos.keytab).

The name (`eos-qdb`, `eos-mgm`, ...) passed to Helm is relevant as it will be reflected in the DNS name of the component.

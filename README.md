# eos-charts

Helm Charts for EOS deployment on Kubernetes

The deployment consists of a fully-fledge EOS cluster with:
- 1 MGM pod, being the headnode of the cluster;
- 3 QuarkDB pods, for highly available namespace and instance configuration;
- 1 MQ pod, for messaging across the different EOS components;
- 4 FST pods, acting as storage daemons to write files' payload.

The default configuration provided is intended for demo purposes and no persistent storage is used. Instance configuration and stored files will be irremediably lost upon the restart of containers.


### How to install EOS Helm charts

To install EOS using helm charts:
```
helm repo add eos https://registry.cern.ch/chartrepo/eos
helm install eos eos/server
```

The name of the deployment in Helm (`eos` in the above example) will be reflected in the DNS name of each component (e.g., `eos-mgm`, `eos-fst`, ...).


The resulting cluster, from the Kubernetes perspective:
```
#  kubectl get pods
NAME        READY   STATUS    RESTARTS   AGE
eos-fst-0   1/1     Running   0          4m47s
eos-fst-1   1/1     Running   0          79s
eos-fst-2   1/1     Running   0          69s
eos-fst-3   1/1     Running   0          59s
eos-mgm-0   2/2     Running   0          4m47s
eos-qdb-0   1/1     Running   0          4m47s
eos-qdb-1   1/1     Running   0          2m21s
eos-qdb-2   1/1     Running   0          2m6s
```

...and from the EOS perspective:
```
# eos ns
# ------------------------------------------------------------------------------------
# Namespace Statistics
# ------------------------------------------------------------------------------------
ALL      Files                            5 [booted] (0s)
ALL      Directories                      11
ALL      Total boot time                  0 s
# ------------------------------------------------------------------------------------
ALL      Compactification                 status=off waitstart=0 interval=0 ratio-file=0.0:1 ratio-dir=0.0:1
# ------------------------------------------------------------------------------------
ALL      Replication                      mode=master-rw state=master-rw master=eos-mgm-0.eos-mgm.default.svc.cluster.local configdir=/var/eos/config/ config=default
# ------------------------------------------------------------------------------------
{...cut...}

# eos fs ls
┌───────────────────────────────────────────┬────┬──────┬────────────────────────────────┬────────────────┬────────────────┬────────────┬──────────────┬────────────┬────────┬────────────────┐
│host                                       │port│    id│                            path│      schedgroup│          geotag│        boot│  configstatus│       drain│  active│          health│
└───────────────────────────────────────────┴────┴──────┴────────────────────────────────┴────────────────┴────────────────┴────────────┴──────────────┴────────────┴────────┴────────────────┘
 eos-fst-0.eos-fst.default.svc.cluster.local 1095      1                     /fst_storage        default.0      docker::k8s       booted             rw      nodrain   online              N/A 
 eos-fst-1.eos-fst.default.svc.cluster.local 1095      2                     /fst_storage        default.1      docker::k8s       booted             rw      nodrain   online              N/A 
 eos-fst-2.eos-fst.default.svc.cluster.local 1095      3                     /fst_storage        default.2      docker::k8s       booted             rw      nodrain   online              N/A 
 eos-fst-3.eos-fst.default.svc.cluster.local 1095      4                     /fst_storage        default.3      docker::k8s       booted             rw      nodrain   online              N/A 
```


### Notes and Limitations

Note: Currently the deployment fails without the `eos.keytab` secret. In order to deploy the required secret run:
```
kubectl create secret generic eos-sss-keytab --from-file=files/eos.keytab
```
The eos.keytab can be found [here](https://github.com/sciencebox/charts/blob/master/sciencebox/files/eos.keytab).


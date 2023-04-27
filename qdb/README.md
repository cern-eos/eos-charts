# qdb

An EOS QDB chart

![Version: 0.1.3](https://img.shields.io/badge/Version-0.1.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 4.8.78](https://img.shields.io/badge/AppVersion-4.8.78-informational?style=flat-square)

Helm Chart to deploy Quark DB.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://registry.cern.ch/eos/charts | utils | 0.1.7 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| clusterID | string | `"24964842-7852-48fd-bbb9-43beb5bfeea9"` | The clusted ID is just a random string that identifies the cluster uniquely    See the docs at https://quarkdb.web.cern.ch/quarkdb/docs/master/configuration/ |
| customLabels | object | `{"component":"eos-qdb","service":"eos"}` | Custom labels to identify eos qdb pod(s).    They are used by node selection, if enabled (see above).    Label nodes accordingly to avoid scheduling problems. |
| dnsPolicy | string | `"ClusterFirst"` | dnsPolicy regulates how the pod resolves hostnames with DNS servers.    In case hostNetwork is set to true, dnsPolicy must be ClusterFirstWithHostNet    Documentation: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/    Available options: Default, ClusterFirst, ClusterFirstWithHostNet, None    Default: ClusterFirst |
| extraEnv | object | `{}` |  |
| hostNetwork | bool | `false` | Network configuration.    hostNetwork allows the pod to use the host network namespace.     Available options: true, false     Default: false |
| image.pullPolicy | string | `"Always"` | QDB image pull policy |
| image.repository | string | `"gitlab-registry.cern.ch/dss/eos/eos-all"` | image repository for qdb |
| image.tag | string | `"4.8.78"` | QDB image tag |
| persistence | object | `{"accessModes":["ReadWriteOnce"],"annotations":{},"enabled":false,"existingClaim":"","size":"32Gi","storageClass":""}` | Manage persistence of data stored in QDB,     namely the instance configuration and the namespace data.     If persistence is not enabled, data stored in QDB will not survive the restart of pods.    It is recommended to configure persistence according to the hosting infrastrcuture.     The persistency can be configured by setting the `enabled` flag:      - false:     No persistence provided. Data is stored in emptyDir volumes.      - true:     Persistence provided by mounting a PersistentVolume via a claim. Requires either:       - a dynamic provisioner (for example, on Openstack, Cinder CSI or Manila CSI), or       - statically provisioned PersistentVolumes pre-created by an administrator      When using a shared filesystem as persistent backend, each PV must live in a separate directory.     This is handed automatically in the case of a dynamic provisioner,     and must be configured manually (by use of 'path' and 'claimRef') in the case of static PVs.       Docs: https://kubernetes.io/docs/concepts/storage/persistent-volumes/      Additional parameters:     - storageClass: If set to "-", disable dynamic provisioning.                     If undefined or null, the default provisioner is chosen.     - accessModes: How to access the pvc (ReadWriteOnce, ReadOnlyMany, ReadWriteMany)     - size: Size of the pvs (example, 10Gi)     - annotations: Custom annotations on the pvc, in key:value format     The persistence type can be overriden via .Values.global.persistence.enabled. |
| podAssignment | object | `{"enableNodeSelector":false,"enablePodAntiAffinity":false}` | Assign qdb pod to a node with a specific label    and distribute them on different nodes to avoid single points of failure. |
| podAssignment.enableNodeSelector | bool | `false` | If true, requires a node labeled as per customLabels (see below) |
| podAssignment.enablePodAntiAffinity | bool | `false` | Shard the cluster members on different nodes |
| ports | object | `{"xrootd_qdb":null}` | Service ports declaration for qdb.    These are the ports exposed by the Kubernetes service.     Defaults:     - xrootd_qdb: 7777    Values can be overridden with:     - .Values.ports.xrootd_qdb below     - Global .Values.global.ports.xrtood_qdb in a parent chart.     Global takes precedence over local values. |
| probes.liveness | bool | `true` |  |
| probes.readiness | bool | `true` |  |
| replicaCount | int | `3` | Set replicaCount to:     1 for standalone operation     3 (or more) to create a distributed cluster with raft consensus replication |
| securityContext | object | `{"allowPrivilegeEscalation":false,"privileged":false}` | Security context.    Define the security context for all containers (including initContainers) of the fst pod.   Docs at https://kubernetes.io/docs/tasks/configure-pod-container/security-context/    Default:     - privileged: false     - allowPrivilegeEscalation: false |
| securityContext.allowPrivilegeEscalation | bool | `false` | If true, a process can gain more privileges than its parent process. |
| securityContext.privileged | bool | `false` | If true, the container will run in privileged mode. |
| sssKeytab | object | `{"secret":""}` | SSS keytab (needed to authenticate against other EOS components).     The name of the kubernetes secret containing the eos keytab to use.    Can be helpful when when deploying qdb in standalone mode using a custom keytab.     Warning: This chart does not automatically create any secret.    The secret storing they key should be pre-created and its name passed here.    Docs to create secrets: https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/     When creating the secret, the key in the data fragment must be 'eos.keytab':       ~# kubectl create secret generic test-keytab --from-file=eos.keytab       secret/test-keytab created       ~# kubectl describe secret test-keytab       [...]       Data       ====       eos.keytab:  138 bytes     Default: eos-sss-keytab    Can be overriden by .Values.global.sssKeytab.secret |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)


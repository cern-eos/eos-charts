# fst

![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 4.8.78](https://img.shields.io/badge/AppVersion-4.8.78-informational?style=flat-square)

An EOS FST chart

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://registry.cern.ch/chartrepo/eos | utils | 0.1.4 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| customLabels | object | `{"component":"eos-fst","service":"eos"}` | Custom labels to identify eos fst pods.    They are used by node selection, if enabled (see above).   Label nodes accordingly to avoid scheduling problems.  |
| dnsPolicy | string | `"ClusterFirst"` | dnsPolicy regulates how the pod resolves hostnames with DNS servers.    In case hostNetwork is set to true, dnsPolicy must be ClusterFirstWithHostNet    Documentation: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/    Available options: Default, ClusterFirst, ClusterFirstWithHostNet, None    Default: ClusterFirst |
| extraEnv | object | `{}` |  |
| geotag | string | `""` | EOS GeoTag    Tag storage node with their geographical location   Docs: https://eos-docs.web.cern.ch/configuration/geotags.html    Defaults to "docker::k8s"   GeoTag can be overriden with:    - .Values.geotag    - Global .Values.global.hostname.eos.geotag in a parent chart.    Global takes precedence over local values. |
| global.clusterDomain | string | `"cluster.local"` | Set this to the domain name of your cluster if it does not use the kubernetes default. |
| hostNetwork | bool | `false` | Network configuration.    hostNetwork allows the pod to use the host network namespace.     Available options: true, false     Default: false |
| hostnames | object | `{"mgm":"","mq":"","qdbcluster":""}` | Short hostnames of the components to be reached from the fst.    The corresponding FQDNs are generated appending the namespace and '.svc.{{ .Values.global.clusterDomain }}'.    These values depend on the Helm release name given to each component.    Leave them blank to let Helm infer the names automatically according to .Release.Name    Values can be overriden with:      - .Values.hostnames.{mgm, mq, qdbcluster}      - Global .Values.global.hostnames.{mgm, mq, qdbcluster} in a parent chart.     Global takes precedence over local values. |
| hostnames.mgm | string | `""` | Hostname of the mgm. |
| hostnames.mq | string | `""` | Hostname of the mq (aka, broker) |
| hostnames.qdbcluster | string | `""` | Hostname of the quarkdb cluster. |
| image.pullPolicy | string | `"Always"` | FST image pullPolicy |
| image.repository | string | `"gitlab-registry.cern.ch/dss/eos/eos-all"` | image repository for fst image |
| image.tag | string | `"4.8.78"` | FST image tag |
| minFsSizeGb | int | `5` | EOS minimum size of filesystem on FST to allow writes    See EOS_FS_FULL_SIZE_IN_GB in    https://gitlab.cern.ch/dss/eos/-/blob/master/fst/storage/Storage.cc |
| persistence | object | `{"accessModes":["ReadWriteOnce"],"annotations":{},"enabled":false,"size":"1Ti","storageClass":""}` | Manage persistence of data stored by FSTs, namely the actual bytes of files stored in EOS.     If persistence is not enabled, data stored in FSTs will not survive the restart of pods.    It is recommended to configure persistence according to the hosting infrastrcuture.     The persistency can be configured by setting the `enabled` flag:     - false:       No persistence provided. Data is stored in emptyDir volumes.     - true:       Persistence provided by mounting a PersistentVolume via a claim. Requires either:       - a dynamic provisioner (for example, on Openstack, Cinder CSI or Manila CSI), or       - statically provisioned PersistentVolumes pre-created by an administrator      Note that each FST requires its own separate and independent storage location.     When using a shared filesystem as persistent backend, each PV must live in a separate directory.     This is handed automatically in the case of a dynamic provisioner,     and must be configured manually (by use of 'path' and 'claimRef') in the case of static PVs.       Docs: https://kubernetes.io/docs/concepts/storage/persistent-volumes/      Additional parameters:     - storageClass: If set to "-", disable dynamic provisioning.                     If undefined or null, the default provisioner is chosen.     - accessModes: How to access the pvc (ReadWriteOnce, ReadOnlyMany, ReadWriteMany)     - size: Size of the pvs (example, 10Gi)     - annotations: Custom annotations on the pvc, in key:value format  The persistence type can be overriden via .Values.global.persistence.enabled.  |
| podAssignment | object | `{"enableNodeSelector":false,"enablePodAntiAffinity":true}` | Assign fst pods to a node with a specific label    and distribute them on different nodes to avoid single points of failure.  |
| podAssignment.enableNodeSelector | bool | `false` | If true, requires a node labeled as per customLabels. |
| podAssignment.enablePodAntiAffinity | bool | `true` | If true, shard the stateful set on as many nodes as possible.    Highly recommended for production scenarios. |
| ports | object | `{"microhttp":null,"xrootd_fst":null}` | Service port declaration for fst.    These are the ports exposed by the Kubernetes service.    Defaults:     - xrootd_fst: 1095     - microhttp:  8001   Values can be overridden with:   - .Values.ports.{xrtood_fst, microhttp} below   - Global .Values.global.ports.<service_name> in a parent chart.     Global takes precedence over local values. |
| probes.liveness | bool | `true` |  |
| replicaCount | int | `4` |  |
| selfRegister | object | `{"config":"rw","enable":true,"groupmod":24,"groupsize":0,"space":"default"}` | Self-registration of the FST filesystem in EOS    When enabled, the FST will register the available filesystem upon booting.    It is possible to configure:     - the eos space where the file system should be added,     - how many filesystems can end up in one scheduling group,     - the maximum number of groups in the space,     - the configuration of the filesystem (rw|wo|ro|drain|draindead|off|empty).   Note:     - <groupsize>=0 means that no groups are built within a space. Must be an integer <=1024.     - <groupmod>=24 comes as default per eos internals. Must be an integer <=256. |
| sssKeytab | object | `{"secret":null}` | SSS keytab (needed to authenticate against other EOS components).    The name of the kubernetes secret containing the eos keytab to use.   Can be helpful when deploying fst in standalone mode using a custom keytab.    Warning: This chart does not automatically create any secret.     The secret storing they key should be pre-created and its name passed here.     Docs to create secrets: https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/    When creating the secret, the key in the data fragment must be 'eos.keytab':     ~# kubectl create secret generic test-keytab --from-file=eos.keytab     secret/test-keytab created     ~# kubectl describe secret test-keytab     [...]     Data     ====     eos.keytab:  138 bytes    Default: eos-sss-keytab     Can be overriden by .Values.global.sssKeytab.secret |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)

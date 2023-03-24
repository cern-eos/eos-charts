# mq

An EOS MQ chart

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 4.8.78](https://img.shields.io/badge/AppVersion-4.8.78-informational?style=flat-square)

Helm Chart to deploy EOS MQ.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://registry.cern.ch/chartrepo/eos | utils | 0.1.5 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| customLabels | object | `{"component":"eos-mq","service":"eos"}` | Custom labels to identify eos mq pod.     They are used by node selection, if enabled (see above).    Label nodes accordingly to avoid scheduling problems. |
| dnsPolicy | string | `"ClusterFirst"` | dnsPolicy regulates how the pod resolves hostnames with DNS servers.    In case hostNetwork is set to true, dnsPolicy must be ClusterFirstWithHostNet    Documentation: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/    Available options: Default, ClusterFirst, ClusterFirstWithHostNet, None    Default: ClusterFirst |
| extraEnv | object | `{}` |  |
| global.clusterDomain | string | `"cluster.local"` | Set this to the domain name of your cluster if it does not use the kubernetes default. |
| hostNetwork | bool | `false` | Network configuration.    hostNetwork allows the pod to use the host network namespace.    Available options: true, false    Default: false |
| hostnames | object | `{"mgm":"","qdbcluster":""}` | Short hostnames of the components to be reached from the mq.    The corresponding FQDNs are generated appending the namespace and '.svc.{{ .Values.global.clusterDomain }}'.     These values depend on the Helm release name given to each component.    Leave them blank to let Helm infer the names automatically according to .Release.Name     Values can be overriden with:    - .Values.hostnames.{mgm, qdbcluster}    - Global .Values.global.hostnames.{mgm, qdbcluster} in a parent chart.        Global takes precedence over local values. |
| hostnames.mgm | string | `""` | Hostname of the mgm. |
| hostnames.qdbcluster | string | `""` | Hostname of the quarkdb cluster. |
| image.pullPolicy | string | `"Always"` | image pull policy |
| image.repository | string | `"gitlab-registry.cern.ch/dss/eos/eos-all"` | image repository for eos mq |
| image.tag | string | `"4.8.78"` | image tag for mq image |
| podAssignment | object | `{"enableMgmColocation":false,"enableNodeAffinity":false,"enableNodeSelector":false}` | Assign mq pod to a node with a specific label or express an affinity with the mgm.    Node selection and affinity are mutually exclusive. |
| podAssignment.enableMgmColocation | bool | `false` | If true, assign weight 100 to colocation with 'component: eos-mgm' |
| podAssignment.enableNodeAffinity | bool | `false` | If true, requires a node labeled as 'service: eos' |
| podAssignment.enableNodeSelector | bool | `false` | If true, requires a node labeled as per customLabels (see below).    Set enableNodeAffinity, enableMgmColocation to false. |
| ports | object | `{"xrootd_mq":null}` | Service ports declaration for mq.    These are the ports exposed by the Kubernetes service.     Defaults:    - xrootd_mq: 1097    Values can be overridden with:   - .Values.ports.xrootd_mq below   - Global .Values.global.ports.xrootd_mq in a parent chart.     Global takes precedence over local values. |
| probes | object | `{"liveness":true}` | Enable or disable health probes for mq.    Docs: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/     Liveness Probe:      Checks every 10 seconds whether it is possible to open a TCP socket againsts port 1095.      The mq container will be restarted after 3 failures.     Default: All probes enabled.      This can be overridden with:      - .Values.probes.liveness below      - Global .Values.global.probes.mq_liveness in a parent chart.          Global takes precedence over local values. |
| securityContext | object | `{"allowPrivilegeEscalation":false,"privileged":false}` | Security context.    Define the security context for all containers (including initContainers) of the fst pod.   Docs at https://kubernetes.io/docs/tasks/configure-pod-container/security-context/    Default:     - privileged: false     - allowPrivilegeEscalation: false |
| securityContext.allowPrivilegeEscalation | bool | `false` | If true, a process can gain more privileges than its parent process. |
| securityContext.privileged | bool | `false` | If true, the container will run in privileged mode. |
| sssKeytab | object | `{"secret":""}` | SSS keytab (needed to authenticate against other EOS components).     The name of the kubernetes secret containing the eos keytab to use.    Can be helpful when when deploying mq in standalone mode using a custom keytab.     Warning: This chart does not automatically create any secret.    The secret storing they key should be pre-created and its name passed here.    Docs to create secrets: https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/     When creating the secret, the key in the data fragment must be 'eos.keytab':      ~# kubectl create secret generic test-keytab --from-file=eos.keytab      secret/test-keytab created      ~# kubectl describe secret test-keytab      [...]      Data      ====      eos.keytab:  138 bytes    Default: eos-sss-keytab     Can be overriden by .Values.global.sssKeytab.secret |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)

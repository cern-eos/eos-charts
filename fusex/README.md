# fusex chart

### Helm Chart for the deployment of the EOS Fusex mount.

-----

![Version: 0.1.4](https://img.shields.io/badge/Version-0.1.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 4.8.86](https://img.shields.io/badge/AppVersion-4.8.86-informational?style=flat-square)

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://registry.cern.ch/eos/charts | utils | 0.1.7 |

### What for
This chart provides the ability to run an EOS Fusex mount in a pod.
The EOS mount is exposed on the host via a bind mount so that other containers (or processes running on the host) can access it. The default path on the host is `/eos`.
The chart deploys EOS Fusex clients as a daemonSet that will run on each host of the cluster or on a subset of nodes identified by custom labels.

### Add the eos chart repository
Configure helm by adding the eos chart repository to your repository list
```bash
helm repo add eos https://registry.cern.ch/chartrepo/eos
helm repo update
```

### Install the chart
After having configured the relevant bits (see below), install the chart to deploy the eos fusex mount in your cluster with
```bash
helm upgrade -i fusex eos/fusex -n myproject -f my-eos-configuration.yaml
```

### Basic configuration options
It's necessary to configure the deployment to connect to the correct EOS MGM. You can create a yaml file and pass it to the `helm upgrade` command.
For an example of the configurations available, please have a look at the `values.yaml` file in the chart root directory.
Basic requirements to connect to an existing eos instance are:
  - fusex.config.eos\_mgm\_alias: The fully qualified domain name of the MGM of the instance to connect to;
  - fusex.config.auth: The authetication method of the client with the MGM. The default is SSS (simple shared secret), which requires providing the instance keytab to the fusex client.
  - fusex.keytab: The keytab used by SSS authentication.

### Deploying fusex on a subset of nodes
If the access to EOS is required by only a subset of nodes of your cluster, it is possible to restrict the deployment of the fusex pod to these nodes only.
  1. Enable the node selection by setting `podAssignment.enableNodeSelector: true`.
  2. Define at least one custom label under `customLabels` in the form of key:value. An example is provided.
  3. Label the nodes in your cluster according to the chosen customLabels.

### SSS authentication and keytabs
To use SSS authentication, this must be enabled in the instance configuration and the keytab must be _forwardable_ (i.e., it ends with a '+' sign).
The keytab is passed to the fusex pod as a kubernetes secret. It must be base64-encoded in `values.yaml`.

### Configuring fusex as a trusted gateway
In some cases, it might be required to register the fusex client as a trusted gateway. This must be done on the MGM with the command `eos vid set add gateway <hostname> [krb5|gsi|sss|unix|https|grpc]`.
As kubernetes pods do not use the host network by default, their network identifier as seen by the MGM might unknown and/or change over time. To circumvent this problem, it is recommended to set:
  - fusex.hostNetwork: true
  - fusex.dnsPolicy: ClusterFirstWithHostNet

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| checkMgmOnline | object | `{"enabled":true,"eosMgmUrl":"eos-mgm.default.svc.cluster.local","eosMgmUrlAuto":false}` | Check for the MGM to be online before starting the mount     Parameters:    - enabled: If set to true, an initContainer running `eos ns` will execute before starting the mount    - eosMgmUrlAuto: If set to true, use the FQDN provided by utils.mgm_fqdn.                       This is helpful only when deploying fusex as dependency of a full eos deployment,                       e.g., via the server chart or ScienceBox. Otherwise, it will not be possible to                       infer the FQDN of the mgm automatically. Use eosMgmUrl to set it manually instead.    - eosMgmUrl: Set the FQDN of the MGM manually. In this case, eosMgmUrlAuto should be set to false.                   Example: "eos-mgm.default.svc.cluster.local" will result in the environment variable                             EOS_MGM_URL="root://eos-mgm-0.eos-mgm.default.svc.cluster.local". |
| customLabels | object | `{"component":"swan-users","service":"swan"}` | Custom labels to identify fusex pod.    They are used by node selection, if enabled (see above).    Label nodes accordingly to avoid scheduling problems. |
| deploymentKind | string | `"DaemonSet"` | Deployment kind for fusex pod.    Options:   - DaemonSet: Deploy fusex pod on all nodes of the cluster, or the ones identified by customLabels if using NodeSelector (see below).   - Deployment: Fusex pod is deployed as one-replica pod, mainly meant for testing. |
| dnsPolicy | string | `"ClusterFirst"` |  |
| extraEnv | object | `{}` |  |
| fusex | object | `{"config":{"auth":{"gsi-first":0,"krb5":0,"oauth2":1,"shared_mount":1,"sss":1},"eos_mgm_alias":"eos-mgm.default.svc.cluster.local","options":{"hide_versions":0},"remotemountdir":"/eos"},"enableHostMountpoint":true,"hostMountpoint":"/eos","kerberos":{"clientConfig":{"configMap":"","file":""},"enabled":false},"keytab":{"file":"","secret":"","value":""}}` | Configuration for fusex. |
| fusex.config | object | `{"auth":{"gsi-first":0,"krb5":0,"oauth2":1,"shared_mount":1,"sss":1},"eos_mgm_alias":"eos-mgm.default.svc.cluster.local","options":{"hide_versions":0},"remotemountdir":"/eos"}` | Change eos_mgm_alias to the correct namespace and cluster domain for your deployment. |
| fusex.enableHostMountpoint | bool | `true` | Expose eos mount to the host    - enableHostMountpoint: Enables/disables exposing eos to the host    - hostMountpoint: Path where to expose eos on the host |
| fusex.kerberos | object | `{"clientConfig":{"configMap":"","file":""},"enabled":false}` | kerberos configuration for fusex      Provides kerberos configuration for krb5-based authentication from fusex      Warning: Remember to enable krb5 authentication in fusex.config.auth.krb5       Options:      - enabled: Projects (or not) /etc/krb5.conf from configMap      - clientConfig.file: Path to a file containing the desired krb5 configuration (has priority over configMap)      - clientConfig.configMap: Name of the configMap storing the krb5 configuration |
| fusex.keytab | object | `{"file":"","secret":"","value":""}` | The keytab to connect to the MGM via SSS      Options:        - secret: Use an existing secret (containing the eos keytab) by providing its name        - value: Provide the full keytab as a string              Example: "0 u:daemon g:daemon n:eos-test+ N:69275826269580..."            A secret with name "<release_fullname>-fusex-sss-keytab" will be created from it.            Takes priority over 'secret'.        - file: Provide the path to a file containing the eos keytab.            A secret with name "<release_fullname>-fusex-sss-keytab" will be created from it.            Takes priority over 'value' and 'secret'.      Defaults to a secret named "<release_fullname>-fusex-sss-keytab" |
| global.clusterDomain | string | `"cluster.local"` | Set this to the domain name of your cluster if it does not use the kubernetes default. |
| hostNetwork | bool | `false` | Pod networking    - hostNetwork: Share host network namespace with pod        Docs: https://kubernetes.io/docs/concepts/policy/pod-security-policy/#host-namespaces    - dnsPolicy: Sets the policy for DNS        --> Change to 'ClusterFirstWithHostNet' when 'hostNetwotk: true'        Docs: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/#pod-s-dns-policy |
| hostPID | bool | `true` | Share host process ID namespace with the pod    Docs: https://kubernetes.io/docs/concepts/policy/pod-security-policy/#host-namespaces |
| hostnames | object | `{"mgm":""}` | Short hostnames of the components to be reached from the fusex mount.   The corresponding FQDNs are generated appending the namespace and '.svc.{{ .Values.global.clusterDomain }}'.    These values depend on the Helm release name given to each component.   Leave them blank to let Helm infer the names automatically according to .Release.Name    Values can be overriden with:   - .Values.hostnames.mgm   - Global .Values.global.hostnames.mgm in a parent chart.       Global takes precedence over local values. |
| hostnames.mgm | string | `""` | Hostname of the mgm. |
| image.repository | string | `"gitlab-registry.cern.ch/dss/eos/eos-fusex"` | image repository for the fusex image |
| image.tag | string | `"4.8.86"` | fusex image tag |
| podAssignment | object | `{"enableNodeSelector":false}` | Assign fusex pod to a node with a specific label.    If true, it will be deployed only on nodes labeled as per customLabels (see below).    If false, it will be deployed on all nodes of the cluster (it is a daemonSet). |
| probes.liveness | bool | `true` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)

# mgm

An EOS MGM + MQ chart

![Version: 0.1.7](https://img.shields.io/badge/Version-0.1.7-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 4.8.80](https://img.shields.io/badge/AppVersion-4.8.80-informational?style=flat-square)

Helm Chart to deploy EOS MGM.

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://registry.cern.ch/eos/charts | utils | 0.1.7 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| customLabels.component | string | `"eos-mgm"` |  |
| customLabels.service | string | `"eos"` |  |
| dnsPolicy | string | `"ClusterFirst"` |  |
| extraEnv | object | `{}` |  |
| global.clusterDomain | string | `"cluster.local"` |  |
| hostNetwork | bool | `false` |  |
| hostnames.mgm | string | `""` |  |
| hostnames.mq | string | `""` |  |
| hostnames.qdbcluster | string | `""` |  |
| http | object | `{"enabled":false}` | HTTP access configuration.    At the moment, this in only compatible with the container images produced in the EOS CI.   Proper configuration will be implemented in the future if needed.    Default: false  |
| image.pullPolicy | string | `"Always"` |  |
| image.repository | string | `"gitlab-registry.cern.ch/dss/eos/eos-all"` |  |
| image.tag | string | `"4.8.80"` |  |
| kerberos.adminPrinc.name | string | `""` |  |
| kerberos.adminPrinc.password | string | `""` |  |
| kerberos.clientConfig.configMap | string | `""` |  |
| kerberos.clientConfig.file | string | `""` |  |
| kerberos.defaultRealm | string | `"example.com"` |  |
| kerberos.enabled | bool | `false` |  |
| ldapBindUsers.enable | bool | `false` |  |
| ldapBindUsers.nscd.image.repository | string | `"gitlab-registry.cern.ch/sciencebox/docker-images/nscd"` |  |
| ldapBindUsers.nscd.image.tag | string | `"stable"` |  |
| ldapBindUsers.nslcd.config.ldap_base | string | `"dc=example,dc=org"` |  |
| ldapBindUsers.nslcd.config.ldap_binddn | string | `"cn=admin,dc=example,dc=org"` |  |
| ldapBindUsers.nslcd.config.ldap_bindpw | string | `"admin"` |  |
| ldapBindUsers.nslcd.config.ldap_filter_group | string | `"(objectClass=group)"` |  |
| ldapBindUsers.nslcd.config.ldap_filter_passwd | string | `"(objectClass=posixAccount)"` |  |
| ldapBindUsers.nslcd.config.ldap_group_search_base | string | `"ou=groups,dc=example,dc=org"` |  |
| ldapBindUsers.nslcd.config.ldap_uri | string | `"ldap://my-ldap-server:12345"` |  |
| ldapBindUsers.nslcd.config.ldap_user_search_base | string | `"dc=example,dc=org"` |  |
| ldapBindUsers.nslcd.image.repository | string | `"gitlab-registry.cern.ch/sciencebox/docker-images/nslcd"` |  |
| ldapBindUsers.nslcd.image.tag | string | `"stable"` |  |
| mgmofs.instance | string | `""` |  |
| persistence.accessModes[0] | string | `"ReadWriteOnce"` |  |
| persistence.annotations | object | `{}` |  |
| persistence.enabled | bool | `false` |  |
| persistence.size | string | `"10Gi"` |  |
| persistence.storageClass | string | `""` |  |
| podAssignment.enableNodeSelector | bool | `false` |  |
| ports.fusex | string | `nil` |  |
| ports.xrootd_https | string | `nil` |  |
| ports.xrootd_mgm | string | `nil` |  |
| ports.xrootd_mq | string | `nil` |  |
| probes.liveness | bool | `true` |  |
| probes.readiness | bool | `true` |  |
| probes.startup | bool | `true` |  |
| securityContext | object | `{"allowPrivilegeEscalation":false,"privileged":false}` | Security context.    Define the security context for all containers (including initContainers) of the mgm pod.   Docs at https://kubernetes.io/docs/tasks/configure-pod-container/security-context/    Default:     - privileged: false     - allowPrivilegeEscalation: false |
| securityContext.allowPrivilegeEscalation | bool | `false` | If true, a process can gain more privileges than its parent process. |
| securityContext.privileged | bool | `false` | If true, the container will run in privileged mode. |
| sssKeytab.secret | string | `nil` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)

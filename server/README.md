# EOS Server

## Connecting to an existing LDAP service

```bash
# Deploy the IDP included with oCIS
helm repo add samuel https://SamuAlfageme.github.io/cernboxcharts
helm repo update
helm upgrade -i ocis-idp samuel/ocis

# Enable ldapBindUsers and provide the LDAP settings:
cat << EOF > ldap-settings.yaml
mgm:
  ldapBindUsers:
    enable: true
    nslcd:
     config:
       ldap_uri: ldap://ocis-idp.ocis.svc.cluster.local:9125
       ldap_base: ou=users,dc=example,dc=org
       ldap_binddn: cn=idp,ou=sysusers,dc=example,dc=org
       ldap_bindpw: idp
       ldap_user_search_base: dc=example,dc=org
       ldap_group_search_base: ou=groups,dc=example,dc=org
       ldap_filter_passwd: (objectClass=posixAccount)
       ldap_filter_group: (objectClass=group)
EOF

helm upgrade -i eos eos/server -f ldap-settings.yaml


# Verify the name resolution is working:
kubectl exec -ti eos-mgm-0 -c eos-mgm -- id marie
```

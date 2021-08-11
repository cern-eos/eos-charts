{{/*
A default krb5.conf kerberos client configuration, framed by a configMap
  Just plug the content expected from kuberos@1.0 defaults and creates the cfgmap 'krb5-conf' out of it.
*/}}
{{- define "utils.krb5Conf" -}}
apiVersion: v1
kind: ConfigMap
metadata:
  name: krb5-conf
data:
  krb5.conf: |-
    [libdefaults]
      default_realm = EXAMPLE.COM
      dns_lookup_realm = false
      dns_lookup_kdc = true
      rdns = false
      ticket_lifetime = 24h
      forwardable = true
      udp_preference_limit = 0
      permitted_enctypes = aes256-cts-hmac-sha1-96 aes256-cts-hmac-sha384-192 camellia256-cts-cmac aes128-cts-hmac-sha1-96 aes128-cts-hmac-sha256-128 camellia128-cts-cmac

    [realms]
      EXAMPLE.COM = {
       kdc = kuberos-kuberos-kdc.{{ .Release.Namespace }}.svc.cluster.local:88
       master_kdc = kuberos-kuberos-kdc.{{ .Release.Namespace }}.svc.cluster.local:88
       admin_server = kuberos-kuberos-kadmin.{{ .Release.Namespace }}.svc.cluster.local:749
       default_domain = cluster.local
       ; pkinit_anchors = FILE:/path/to/kdc-ca-bundle.pem
       ; pkinit_pool = FILE:/path/to/ca-bundle.pem
      }
{{- end -}}

{{/*
Create a default krb5.conf kerberos client configuration as configMap
  Used by mgm and fusex if kerberos is enabled

#TODO: This should be properly templated
#TODO: This is not used at the moment
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
       kdc = kuberos-kuberos-kdc.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:88
       master_kdc = kuberos-kuberos-kdc.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:88
       admin_server = kuberos-kuberos-kadmin.{{ .Release.Namespace }}.svc.{{ .Values.global.clusterDomain }}:749
       default_domain = {{ .Values.global.clusterDomain }}
       ; pkinit_anchors = FILE:/path/to/kdc-ca-bundle.pem
       ; pkinit_pool = FILE:/path/to/ca-bundle.pem
      }
{{- end -}}

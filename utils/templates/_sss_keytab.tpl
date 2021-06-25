{{/*
Name of the secret storing the SSS keytab
  - Global value '.Values.global.sssKeytab.secret' has highest priority
  - Local value '.Values.sssKeytab.secret' has lower priority
  - Default is 'eos-sss-keytab'
*/}}
{{- define "utils.sssKeytabName" -}}
{{- $sssNameDefault := printf "eos-sss-keytab" -}}
{{- $sssNameLocal := "" -}}
{{- $sssNameGlobal := "" -}}
{{- if .Values.global }}
  {{- $sssNameGlobal = dig "sssKeytab" "secret" "" .Values.global -}}
{{- end }}
{{- if .Values.sssKeytab -}}
  {{- $sssNameLocal = dig "secret" "" .Values.sssKeytab -}}
{{- end }}
{{- coalesce $sssNameGlobal $sssNameLocal $sssNameDefault }}
{{- end }}

{{/*
Path to the file storing the SSS keytab
  - Global value '.Values.global.sssKeytab.file' has highest priority
  - Default is 'files/eos.keytab' (relative to the path of the calling chart)
*/}}
{{- define "utils.sssKeytabFile" -}}
{{- dig "sssKeytab" "file" "files/eos.keytab" .Values.global -}}
{{- end }}

{{/*
The SSS keytab secret
  Read file at the location given by 'utils.sssKeytabFile' and creates the secret 'eos-sss-keytab' out of it.
  The key of the secret in the data fragment is always 'eos.keytab' to avoid naming mismatch
    when projecting the secret as a file.
  If the source file doe not exist (or it is empty), no secrets will be created.
*/}}
{{- define "utils.sssKeytab" -}}
{{- $keytab := .Files.Get (include "utils.sssKeytabFile" .) }}
{{- if $keytab -}}
apiVersion: v1
kind: Secret
metadata:
  name: eos-sss-keytab
type: Opaque
data:
  eos.keytab: |-
    {{ $keytab | b64enc }}
immutable: false
{{- end }}
{{- end -}}

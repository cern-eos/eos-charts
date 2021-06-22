{{/*
Name of the secret storing the SSS keytab
  - Global value '.Values.global.sssKeytab.name' has highest priority
  - Local value '.Values.sssKeytab.name' has lower priority
  - Default is 'eos-sss-keytab'
*/}}
{{- define "utils.sssKeytabName" -}}
{{- $sssNameDefault := printf "eos-sss-keytab" -}}
{{- $sssNameLocal := "" -}}
{{- $sssNameGlobal := "" -}}
{{- if .Values.global }}
  {{- $sssNameGlobal = dig "sssKeytab" "name" "" .Values.global -}}
{{- end }}
{{- if .Values.sssKeytab -}}
  {{- $sssNameLocal = dig "name" "" .Values.sssKeytab -}}
{{- end }}
{{- coalesce $sssNameGlobal $sssNameLocal $sssNameDefault }}
{{- end }}

{{/*
Path to the file storing the SSS keytab
  - Global value '.Values.global.sssKeytab.file' has highest priority
  - Local value '.Values.sssKeytab.file' has lower priority
  - Default is 'files/eos.keytab' (relative to the path of the calling chart)
*/}}
{{- define "utils.sssKeytabFile" -}}
{{- $sssFileDefault := printf "files/eos.keytab" -}}
{{- $sssFileLocal := "" -}}
{{- $sssFileGlobal := "" -}}
{{- if .Values.global }}
  {{- $sssFileGlobal = dig "sssKeytab" "file" "" .Values.global -}}
{{- end }}
{{- if .Values.sssKeytab -}}
  {{- $sssFileLocal = dig "file" "" .Values.sssKeytab -}}
{{- end }}
{{- coalesce $sssFileGlobal $sssFileLocal $sssFileDefault }}
{{- end }}

{{/*
The SSS keytab secret
  Read file at the location given by 'utils.sssKeytabFile' and creates the secret 'eos-sss-keytab' out of it.
  It also makes sure that the key of the secret in the data fragment is always 'eos.keytab'
    to avoid naming problems when projecting the secret as a file.
*/}}
{{- define "utils.sssKeytab" -}}
apiVersion: v1
kind: Secret
metadata:
  name: eos-sss-keytab
type: Opaque
data:
  eos.keytab: |-
    {{ .Files.Get (include "utils.sssKeytabFile" .) | b64enc }}
immutable: false
{{- end -}}

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
The SSS keytab itself.
  Read from file in '<component_name>/files/eos.keytab'.
  <component_name> is because helm uses the working directory of the chart calling the utils functions.
*/}}
{{- define "utils.sssKeytab" -}}
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "utils.sssKeytabName" . }}
type: Opaque
data:
  {{ (.Files.Glob "files/eos.keytab").AsSecrets }}
immutable: false
{{- end -}}

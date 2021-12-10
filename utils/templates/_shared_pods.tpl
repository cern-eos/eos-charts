{{/*
Share pod between MGM and MQ containers

Colocate mgm and mq containers in the same pod
  - Global value '.Values.global.samePodMgmMq'
  - Default: true
*/}}
{{- define "podSharing.mgmMq" -}}
{{- if .Values.global -}}
  {{- if ( eq ( .Values.global.splitMgmMq | toString ) "true" ) -}}
    {{- printf "false" -}}
  {{- else -}}
    {{- printf "true" -}}
  {{- end -}}
{{- else -}}
{{- printf "true" -}}
{{- end }}
{{- end }}

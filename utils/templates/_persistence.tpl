{{/*
Persistence definition
*/}}
{{- define "utils.persistence" -}}
{{- $persistenceDefault := "false" -}}
{{- $persistenceLocal := "" -}}
{{- $persistenceGlobal := "" -}}
{{- if .Values.persistence -}}
  {{- $persistenceLocal = (dig "enabled" "" .Values.persistence | toString) -}}
{{- end }}
{{- if .Values.global -}}
  {{- $persistenceGlobal = (dig "persistence" "enabled" "" .Values.global | toString) }}
{{- end }}
{{- lower (coalesce $persistenceGlobal $persistenceLocal $persistenceDefault) }}
{{- end }}

{{/*
HTTP access definition
  Used to allow HTTP access by enabling http configuration blocks in `xrd.cf.{mgm, fst}`.
*/}}
{{- define "utils.httpAccess.enabled" }}
{{- $httpEnabledGlobal := "" -}}
{{- $httpEnabledLocal := "" -}}
{{- if .Values.global -}}
  {{ $httpEnabledGlobal = dig "http" "enabled" "" .Values.global }}
{{- end }}
{{- if .Values.http -}}
  {{ $httpEnabledLocal = dig "enabled" "" .Values.http }}
{{- end }}
{{- if $httpEnabledGlobal }}
  {{- printf "%v" $httpEnabledGlobal }}
{{- else if $httpEnabledLocal }}
  {{- printf "%v" $httpEnabledLocal }}
{{- else }}
  {{- printf "false" }}
{{- end }}
{{- end }}

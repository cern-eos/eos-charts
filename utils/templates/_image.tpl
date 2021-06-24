{{/*
Return the proper EOS image name:tag
*/}}
{{- define "utils.image" -}}
{{- $repositoryName := .Values.image.repository -}}
{{- $tag := .Values.image.tag | toString -}}

{{- if .Values.global }}
    {{- if and .Values.global.repository .Values.global.tag }}
        {{- printf "%s:%s" .Values.global.repository .Values.global.tag -}}
    {{- else if .Values.global.repository -}}
        {{- printf "%s:%s" .Values.global.repository $tag -}}
    {{- else if .Values.global.tag -}}
        {{- printf "%s:%s" $repositoryName .Values.global.tag -}}
    {{- else -}}
        {{- printf "%s:%s" $repositoryName $tag -}}
    {{- end -}}
{{- else -}}
    {{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{/*
Return the image pull policy
*/}}
{{- define "utils.imagePullPolicy" -}}
{{- $policyDefault := "Always" -}}
{{- $policyLocal := "" -}}
{{- $policyGlobal := "" -}}
{{- if .Values.global -}}
  {{ $policyGlobal = dig "pullPolicy" "" .Values.global -}}
{{- end }}
{{- if .Values.image -}}
  {{ $policyLocal = dig "pullPolicy" "" .Values.image -}}
{{- end }}
{{- coalesce $policyGlobal $policyLocal $policyDefault }}
{{- end -}}

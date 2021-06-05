{{/* vim: set filetype=mustache: */}}


{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kerberos.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{- define "kerberos.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "kerberos.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Create the name of the kerberos service account.
*/}}
{{- define "kerberos.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "kerberos.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}



{{/*
Common labels
*/}}
{{- define "kerberos.labels" -}}
helm.sh/chart: {{ include "kerberos.chart" . }}
{{ include "kerberos.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "kerberos.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kerberos.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

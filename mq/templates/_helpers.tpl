{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mq.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mq.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mq.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "mq.labels" -}}
helm.sh/chart: {{ include "mq.chart" . }}
{{ include "mq.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "mq.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mq.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "mq.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "mq.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Namespace definition
*/}}
{{- define "mq.namespace" -}}
{{- $namespace := default "default" .Values.namespace -}}
{{- if .Values.global -}}
    {{ dig "namespace" $namespace .Values.global }}
{{- else -}}
    {{ $namespace }}
{{- end }}
{{- end }}

{{/*
MGM hostname definition
*/}}
{{- define "mgm.hostname" -}}
{{- if .Values.global }}
  {{- .Values.global.hostnames.mgm }}
{{- else }}
  {{- .Values.hostnames.mgm }}
{{- end }}
{{- end }}

{{/*
MGM FQDN definition
  To set environment variables, e.g., EOS_MGM_MASTER1/2, EOS_MGM_ALIAS, ...
*/}}
{{- define "mgm.fqdn" -}}
{{- if .Values.global }}
  {{- printf "%s-0.%s.%s.svc.cluster.local" .Values.global.hostnames.mgm .Values.global.hostnames.mgm .Release.Namespace }}
{{- else }}
  {{- printf "%s-0.%s.%s.svc.cluster.local" .Values.hostnames.mgm .Values.hostnames.mgm .Release.Namespace }}
{{- end }}
{{- end }}

{{/*
QDB cluster hostname definition
*/}}
{{- define "qdbcluster.hostname" -}}
{{- if .Values.global }}
  {{- .Values.global.hostnames.qdbcluster }}
{{- else }}
  {{- .Values.hostnames.qdbcluster }}
{{- end }}
{{- end }}

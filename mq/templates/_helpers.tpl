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
MQ network ports definition
  - xrootd mq port (defaults to 1097)

All the ports can be set according to (example for xrootd_mq):
  - Global value '.Values.global.ports.xrootd_mq' (has the highest priority)
  - Local value '.Values.ports.xrootd_mq' (has lower priority)
  - Default value (shown above for each port)
*/}}
{{- define "mq.service.port.xrootd_mq" -}}
{{- $xrootd_mqDefault := "1097" -}}
{{- $xrootd_mqLocal := "" -}}
{{- $xrootd_mqGlobal := "" -}}
{{- if .Values.ports -}}
  {{ $xrootd_mqLocal = dig "xrootd_mq" "" .Values.ports -}}
{{- end }}
{{- if .Values.global -}}
  {{ $xrootd_mqGlobal = dig "ports" "xrootd_mq" "" .Values.global -}}
{{- end }}
{{- coalesce $xrootd_mqGlobal $xrootd_mqLocal $xrootd_mqDefault }}
{{- end }}

{{/*
Liveness Probe definition
*/}}
{{- define "mq.livenessProbe" -}}
{{- $livenessEnabled := "true" -}}
{{- if .Values.probes -}}
  {{- $livenessEnabled = dig "liveness" $livenessEnabled .Values.probes -}}
{{- end }}
{{- if .Values.global -}}
  {{- $livenessEnabled = dig "probes" "mq_liveness" $livenessEnabled .Values.global }}
{{- end }}
{{- if $livenessEnabled -}}
livenessProbe:
  tcpSocket:
    port: 1097
  initialDelaySeconds: 5
  periodSeconds: 10
  successThreshold: 1
  failureThreshold: 3
{{- end }}
{{- end }}

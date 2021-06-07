{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "fusex.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fusex.fullname" -}}
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
{{- define "fusex.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "fusex.labels" -}}
helm.sh/chart: {{ include "fusex.chart" . }}
{{ include "fusex.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "fusex.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fusex.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "fusex.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "fusex.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/* Liveness Probe definition
*/}}
{{- define "fusex.livenessProbe" -}}
{{- $livenessEnabled := "true" -}}
{{- if .Values.probes -}}
  {{- $livenessEnabled = dig "liveness" $livenessEnabled .Values.probes -}}
{{- end }}
{{- if .Values.global -}}
  {{- $livenessEnabled = dig "probes" "fusex_liveness" $livenessEnabled .Values.global }}
{{- end }}
{{- if $livenessEnabled -}}
livenessProbe:
  exec:
    command:
    - /usr/sbin/pidof
    - eosxd
  initialDelaySeconds: 5
  periodSeconds: 10
  successThreshold: 1
  failureThreshold: 3
{{- end }}
{{- end }}

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "qdb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "qdb.fullname" -}}
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
{{- define "qdb.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "qdb.labels" -}}
helm.sh/chart: {{ include "qdb.chart" . }}
{{ include "qdb.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "qdb.selectorLabels" -}}
app.kubernetes.io/name: {{ include "qdb.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "qdb.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "qdb.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Namespace definition
*/}}
{{- define "qdb.namespace" -}}
{{- $namespace := default "default" .Values.namespace -}}
{{- if .Values.global -}}
    {{ dig "namespace" $namespace .Values.global }}
{{- else -}}
    {{ $namespace }}
{{- end }}
{{- end }}

{{/*
Persistence definition
*/}}
{{- define "persistence" -}}
{{- $persistenceDefault := "disabled" -}}
{{- $persistenceLocal := "" -}}
{{- $persistenceGlobal := "" -}}
{{- if .Values.persistence -}}
  {{- $persistenceLocal = dig "type" "" .Values.persistence -}}
{{- end }}
{{- if .Values.global -}}
  {{- $persistenceGlobal = dig "eos" "persistence" "type" "" .Values.global }}
{{- end }}
{{- lower (coalesce $persistenceGlobal $persistenceLocal $persistenceDefault) }}
{{- end }}

{{/*
QDB network ports definition
  - xroot qdb port (defaults to 7777)

All the ports can be set according to (example for xrootd_qdb):
  - Global value '.Values.global.ports.xrootd_qdb' (has the highest priority)
  - Local value '.Values.ports.xrootd_qdb' (has lower priority)
  - Default value (shown above for each port)
*/}}
{{- define "qdb.service.port.xrootd_qdb" -}}
{{- $xrootd_qdbDefault := "7777" -}}
{{- $xrootd_qdbLocal := "" -}}
{{- $xrootd_qdbGlobal := "" -}}
{{- if .Values.ports -}}
  {{ $xrootd_qdbLocal = dig "xrootd_qdb" "" .Values.ports -}}
{{- end }}
{{- if .Values.global -}}
  {{ $xrootd_qdbGlobal = dig "ports" "xrootd_qdb" "" .Values.global -}}
{{- end }}
{{- coalesce $xrootd_qdbGlobal $xrootd_qdbLocal $xrootd_qdbDefault }}
{{- end }}

{{/*
Liveness Probe definition
*/}}
{{- define "qdb.livenessProbe" -}}
{{- $livenessEnabled := "true" -}}
{{- if .Values.probes -}}
  {{- $livenessEnabled = dig "liveness" $livenessEnabled .Values.probes -}}
{{- end }}
{{- if .Values.global -}}
  {{- $livenessEnabled = dig "probes" "qdb_liveness" $livenessEnabled .Values.global }}
{{- end }}
{{- if $livenessEnabled -}}
livenessProbe:
  tcpSocket:
    port: 7777
  initialDelaySeconds: 5
  periodSeconds: 10
  successThreshold: 1
  failureThreshold: 3
{{- end }}
{{- end }}

{{/*
Readiness Probe definition
*/}}
{{- define "qdb.readinessProbe" -}}
{{- $readinessEnabled := "true" -}}
{{- if .Values.probes -}}
  {{- $readinessEnabled = dig "readiness" $readinessEnabled .Values.probes -}}
{{- end }}
{{- if .Values.global -}}
  {{- $readinessEnabled = dig "probes" "qdb_readiness" $readinessEnabled .Values.global }}
{{- end }}
{{- if $readinessEnabled -}}
readinessProbe:
  exec:
    command:
    - /usr/bin/redis-cli
    - -p
    - "7777"
    - ping
  initialDelaySeconds: 5
  periodSeconds: 10
  successThreshold: 1
  failureThreshold: 3
{{- end }}
{{- end }}

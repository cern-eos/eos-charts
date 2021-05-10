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
  - xroot_qdb_httpd mgm port (defaults to 7777)

All the ports can be set according to (example for xrootd_qdb_http):
  - Global value '.Values.global.ports.xrootd_qdb_http' (has the highest priority)
  - Local value '.Values.ports.xrootd_qdb_http' (has lower priority)
  - Default value (shown above for each port)
*/}}
{{- define "mgm.service.port.xrootd_qdb_http" -}}
{{- $xrootd_qdb_httpDefault := "7777" -}}
{{- $xrootd_qdb_httpLocal := "" -}}
{{- $xrootd_qdb_httpGlobal := "" -}}
{{- if .Values.ports -}}
  {{ $xrootd_qdb_httpLocal = dig "xrootd_qdb_http" "" .Values.ports -}}
{{- end }}
{{- if .Values.global -}}
  {{ $xrootd_qdb_httpGlobal = dig "ports" "xrootd_qdb_http" "" .Values.global -}}
{{- end }}
{{- coalesce $xrootd_qdb_httpGlobal $xrootd_qdb_httpLocal $xrootd_qdb_httpDefault }}
{{- end }}

{{/*
StartupProbe definition
*/}}
{{- define "qdb.startupProbe" -}}
  {{- if .Values.startupProbe.enabled }}
startupProbe:
    {{- if .Values.startupProbe.tcpSocket }}
  tcpSocket:
    host: {{ .Values.startupProbe.tcpSocket.host }}
    port: {{ .Values.startupProbe.tcpSocket.port }}
    {{- end }}
  failureThreshold: {{ .Values.startupProbe.failureThreshold }}
  periodSeconds: {{ .Values.startupProbe.periodSeconds }}
{{- else }}
  {{- if .Values.global }}
    {{- with .Values.global }}
      {{- if .qdb.startupProbe.enabled }}
startupProbe:
  tcpSocket:
    host: {{ $.Release.Name }}-mgm
    port: {{ .service.xrootd_mgm.port }}
  failureThreshold: {{ .qdb.startupProbe.failureThreshold }}
  periodSeconds: {{ .qdb.startupProbe.periodSeconds }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

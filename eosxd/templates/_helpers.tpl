{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "eosxd.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "eosxd.fullname" -}}
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
{{- define "eosxd.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "eosxd.labels" -}}
helm.sh/chart: {{ include "eosxd.chart" . }}
{{ include "eosxd.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "eosxd.selectorLabels" -}}
app.kubernetes.io/name: {{ include "eosxd.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "eosxd.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "eosxd.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
StartupProbe definition
*/}}
{{- define "eosxd.startupProbe" -}}
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
      {{- if .eosxd.startupProbe.enabled }}
startupProbe:
  tcpSocket:
    host: {{ $.Release.Name }}-mgm
    port: {{ .service.xrootd_mgm.port }}
  failureThreshold: {{ .eosxd.startupProbe.failureThreshold }}
  periodSeconds: {{ .eosxd.startupProbe.periodSeconds }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

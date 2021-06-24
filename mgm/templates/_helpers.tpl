{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mgm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mgm.fullname" -}}
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
{{- define "mgm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "mgm.labels" -}}
helm.sh/chart: {{ include "mgm.chart" . }}
{{ include "mgm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "mgm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mgm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "mgm.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "mgm.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Namespace definition
*/}}
{{- define "mgm.namespace" -}}
{{- $namespace := default "default" .Values.namespace -}}
{{- if .Values.global -}}
    {{ dig "namespace" $namespace .Values.global }}
{{- else -}}
    {{ $namespace }}
{{- end }}
{{- end }}

{{/*
EOS instance name definition
  Used to set the name of the EOS instance:
  - Global value '.Values.global.eos.instancename' has highest priority
  - Local value '.Values.mgmofs.instance' has lower priority
  - Default value is 'eosdockertest'
*/}}
{{- define "mgm.instancename" -}}
{{- $nameDefault := "eosdockertest" -}}
{{- $nameLocal := "" -}}
{{- $nameGlobal := "" -}}
{{- if .Values.mgmofs -}}
  {{ $nameLocal = dig "instance" "" .Values.mgmofs }}
{{- end }}
{{- if .Values.global -}}
  {{ $nameGlobal = dig "eos" "instancename" "" .Values.global }}
{{- end }}
{{- coalesce $nameGlobal $nameLocal $nameDefault }}
{{- end }}

{{/*
MGM network ports definition
  - xrootd mgm port (defaults to 1094)
  - xrootd sync port (defaults to 1096)
  - xrootd http port (defaults to 8000)
  - xrootd fusex port (defaults to 1100)

All the ports can be set according to (example for xrootd_mgm):
  - Global value '.Values.global.ports.xrootd_mgm' (has the highest priority)
  - Local value '.Values.ports.xrootd_mgm' (has lower priority)
  - Default value (shown above for each port)
*/}}
{{- define "mgm.service.port.xrootd_mgm" -}}
{{- $xrootd_mgmDefault := "1094" -}}
{{- $xrootd_mgmLocal := "" -}}
{{- $xrootd_mgmGlobal := "" -}}
{{- if .Values.ports -}}
  {{ $xrootd_mgmLocal = dig "xrootd_mgm" "" .Values.ports -}}
{{- end }}
{{- if .Values.global -}}
  {{ $xrootd_mgmGlobal = dig "ports" "xrootd_mgm" "" .Values.global -}}
{{- end }}
{{- coalesce $xrootd_mgmGlobal $xrootd_mgmLocal $xrootd_mgmDefault }}
{{- end }}

{{- define "mgm.service.port.xrootd_sync" -}}
{{- $xrootd_syncDefault := "1096" -}}
{{- $xrootd_syncLocal := "" -}}
{{- $xrootd_syncGlobal := "" -}}
{{- if .Values.ports -}}
  {{ $xrootd_syncLocal = dig "xrootd_sync" "" .Values.ports -}}
{{- end }}
{{- if .Values.global -}}
  {{ $xrootd_syncGlobal = dig "ports" "xrootd_sync" "" .Values.global -}}
{{- end }}
{{- coalesce $xrootd_syncGlobal $xrootd_syncLocal $xrootd_syncDefault }}
{{- end }}

{{- define "mgm.service.port.xrootd_http" -}}
{{- $xrootd_httpDefault := "8000" -}}
{{- $xrootd_httpLocal := "" -}}
{{- $xrootd_httpGlobal := "" -}}
{{- if .Values.ports -}}
  {{ $xrootd_httpLocal = dig "xrootd_http" "" .Values.ports -}}
{{- end }}
{{- if .Values.global -}}
  {{ $xrootd_httpGlobal = dig "ports" "xrootd_http" "" .Values.global -}}
{{- end }}
{{- coalesce $xrootd_httpGlobal $xrootd_httpLocal $xrootd_httpDefault }}
{{- end }}

{{- define "mgm.service.port.fusex" -}}
{{- $fusexDefault := "1100" -}}
{{- $fusexLocal := "" -}}
{{- $fusexGlobal := "" -}}
{{- if .Values.ports -}}
  {{ $fusexLocal = dig "fusex" "" .Values.ports -}}
{{- end }}
{{- if .Values.global -}}
  {{ $fusexGlobal = dig "ports" "fusex" "" .Values.global -}}
{{- end }}
{{- coalesce $fusexGlobal $fusexLocal $fusexDefault }}
{{- end }}

{{/*
Startup Probe definition
*/}}
{{- define "mgm.startupProbe" -}}
{{- $startupEnabled := "true" -}}
{{- if .Values.probes -}}
  {{- $startupEnabled = dig "startup" $startupEnabled .Values.probes -}}
{{- end }}
{{- if .Values.global -}}
  {{- $startupEnabled = dig "probes" "mgm_startup" $startupEnabled .Values.global }}
{{- end }}
{{- if $startupEnabled -}}
startupProbe:
  tcpSocket:
    port: 1094
  periodSeconds: 10
  successThreshold: 1
  failureThreshold: 6  # Totals to 60 (6*10s) startup delay
{{- end }}
{{- end }}

{{/*
Liveness Probe definition
*/}}
{{- define "mgm.livenessProbe" -}}
{{- $livenessEnabled := "true" -}}
{{- if .Values.probes -}}
  {{- $livenessEnabled = dig "liveness" $livenessEnabled .Values.probes -}}
{{- end }}
{{- if .Values.global -}}
  {{- $livenessEnabled = dig "probes" "mgm_liveness" $livenessEnabled .Values.global }}
{{- end }}
{{- if $livenessEnabled -}}
livenessProbe:
  tcpSocket:
    port: 1094
  initialDelaySeconds: 5
  periodSeconds: 10
  successThreshold: 1
  failureThreshold: 3
{{- end }}
{{- end }}

{{/*
Readiness Probe definition
*/}}
{{- define "mgm.readinessProbe" -}}
{{- $readinessEnabled := "true" -}}
{{- if .Values.probes -}}
  {{- $readinessEnabled = dig "readiness" $readinessEnabled .Values.probes -}}
{{- end }}
{{- if .Values.global -}}
  {{- $readinessEnabled = dig "probes" "mgm_readiness" $readinessEnabled .Values.global }}
{{- end }}
{{- if $readinessEnabled -}}
readinessProbe:
  exec:
    command:
    - /usr/bin/eos
    - ns
  initialDelaySeconds: 5
  periodSeconds: 10
  timeoutSeconds: 5
  successThreshold: 1
  failureThreshold: 3
{{- end }}
{{- end }}

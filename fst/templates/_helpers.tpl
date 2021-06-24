{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "fst.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "fst.fullname" -}}
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
{{- define "fst.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "fst.labels" -}}
helm.sh/chart: {{ include "fst.chart" . }}
{{ include "fst.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "fst.selectorLabels" -}}
app.kubernetes.io/name: {{ include "fst.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "fst.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "fst.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Namespace definition
*/}}
{{- define "fst.namespace" -}}
{{- $namespace := default "default" .Values.namespace -}}
{{- if .Values.global -}}
    {{ dig "namespace" $namespace .Values.global }}
{{- else -}}
    {{ $namespace }}
{{- end }}
{{- end }}

{{/*
FST network ports definition
  - xrootd fst port (defaults to 1095)
  - microhttp port (defaults to 8001)

All the ports can be set according to (example for fst):
  - Global value '.Values.global.ports.xrootd_fst' (has the highest priority)
  - Local value '.Values.ports.xrootd_fst' (has lower priority)
  - Default value (shown above for each port)
*/}}
{{- define "fst.service.port.xrootd_fst" -}}
{{- $fstDefault := "1095" -}}
{{- $fstLocal := "" -}}
{{- $fstGlobal := "" -}}
{{- if .Values.ports -}}
  {{ $fstLocal = dig "xrootd_fst" "" .Values.ports -}}
{{- end }}
{{- if .Values.global -}}
  {{ $fstGlobal = dig "ports" "xrootd_fst" "" .Values.global -}}
{{- end }}
{{- coalesce $fstGlobal $fstLocal $fstDefault }}
{{- end }}

{{- define "fst.service.port.microhttp" -}}
{{- $microhttpDefault := "8001" -}}
{{- $microhttpLocal := "" -}}
{{- $microhttpGlobal := "" -}}
{{- if .Values.ports -}}
  {{ $microhttpLocal = dig "microhttp" "" .Values.ports -}}
{{- end }}
{{- if .Values.global -}}
  {{ $microhttpGlobal = dig "ports" "microhttp" "" .Values.global -}}
{{- end }}
{{- coalesce $microhttpGlobal $microhttpLocal $microhttpDefault }}
{{- end }}

{{/*
EOS GeoTag definition
  Used to set the geographical tags of storage nodes:
  - Global value '.Values.global.eos.geotag' has highest priority
  - Local value '.Values.geotag ' has lower priority
  - Default value is 'docker::k8s'
*/}}
{{- define "eos.geotag" -}}
{{- $geotag := default "docker::k8s" .Values.geotag -}}
{{- if .Values.global -}}
  {{ dig "eos" "geotag" $geotag .Values.global }}
{{- else -}}
  {{ $geotag }}
{{- end }}
{{- end }}

{{/*
Liveness Probe definition
*/}}
{{- define "fst.livenessProbe" -}}
{{- $livenessEnabled := "true" -}}
{{- if .Values.probes -}}
  {{- $livenessEnabled = dig "liveness" $livenessEnabled .Values.probes -}}
{{- end }}
{{- if .Values.global -}}
  {{- $livenessEnabled = dig "probes" "fst_liveness" $livenessEnabled .Values.global }}
{{- end }}
{{- if $livenessEnabled -}}
livenessProbe:
  tcpSocket:
    port: 1095
  initialDelaySeconds: 5
  periodSeconds: 10
  successThreshold: 1
  failureThreshold: 3
{{- end }}
{{- end }}

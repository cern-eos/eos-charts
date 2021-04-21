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
MGM hostname definition
  Used to set the hostname of the MGM (short format) where:
  - Global value '.Values.global.hostnames.mgm' has highest priority
  - Local value '.Values.hostnames.mgm' has lower priority
  - Default values uses .Release.Name

  - It does not support inferring components name's when not using an umbrella chart
    A previous version was supporting this by using  the release name and appending '-mgm' to it
    The one liner is:
      {{- $mgmDefault := printf "%s-mgm" (splitList "-" .Release.Name | initial | join "-") -}}
*/}}
{{- define "mgm.hostname" -}}
{{- $mgmDefault := printf "%s-mgm" .Release.Name -}}
{{- $mgmLocal := "" -}}
{{- $mgmGlobal := "" -}}
{{- if .Values.hostnames -}}
  {{ $mgmLocal = dig "mgm" "" .Values.hostnames }}
{{- end }}
{{- if .Values.global -}}
  {{- $mgmGlobal = dig "hostnames" "mgm" "" .Values.global -}}
{{- end }}
{{- coalesce $mgmGlobal $mgmLocal $mgmDefault }}
{{- end }}

{{/*
QDB cluster hostname definition
  Used to set the hostname of the QDB cluster (short format).
  See MGM hostname definition for the details on the logic.
*/}}
{{- define "qdbcluster.hostname" -}}
{{- $qdbDefault := printf "%s-qdb" .Release.Name -}}
{{- $qdbLocal := "" -}}
{{- $qdbGlobal := "" -}}
{{- if .Values.hostnames -}}
  {{ $qdbLocal = dig "qdbcluster" "" .Values.hostnames }}
{{- end }}
{{- if .Values.global -}}
  {{- $qdbGlobal = dig "hostnames" "qdbcluster" "" .Values.global -}}
{{- end }}
{{- coalesce $qdbGlobal $qdbLocal $qdbDefault }}
{{- end }}

{{/*
MQ cluster hostname definition
  Used to set the hostname of the MQ (short format).
  See MGM hostname definition for the details on the logic.
*/}}
{{- define "mq.hostname" -}}
{{- $mqDefault := printf "%s-mq" .Release.Name -}}
{{- $mqLocal := "" -}}
{{- $mqGlobal := "" -}}
{{- if .Values.hostnames -}}
  {{ $mqLocal = dig "mq" "" .Values.hostnames }}
{{- end }}
{{- if .Values.global -}}
  {{- $mqGlobal = dig "hostnames" "mq" "" .Values.global -}}
{{- end }}
{{- coalesce $mqGlobal $mqLocal $mqDefault }}
{{- end }}

{{/*
MGM FQDN definition
  Used to set environment variables, e.g., EOS_MGM_MASTER1/2, EOS_MGM_ALIAS, ...
*/}}
{{- define "mgm.fqdn" -}}
{{- $mgmHostname := (include "mgm.hostname" . ) -}}
{{ printf "%s-0.%s.%s.svc.cluster.local" $mgmHostname $mgmHostname .Release.Namespace }}
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
StartupProbe definition
*/}}
{{- define "fst.startupProbe" -}}
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
      {{- if .fst.startupProbe.enabled }}
startupProbe:
  tcpSocket:
    host: {{ $.Release.Name }}-mgm
    port: {{ .service.xrootd_mgm.port }}
  failureThreshold: {{ .fst.startupProbe.failureThreshold }}
  periodSeconds: {{ .fst.startupProbe.periodSeconds }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

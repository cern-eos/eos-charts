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
Services' definition
*/}}
{{- define "mgm.service.xrootd_mgm.port" -}}
{{- $xrootd_mgmDefault := 1094 -}}
{{- $xrootd_mgmLocal := "" -}}
{{- $xrootd_mgmGlobal := "" -}}
{{- if .Values.service -}}
  {{ $xrootd_mgmLocal := dig "xrootd_mgm" "port" "" .Values.service -}}
{{- end}}
{{- if .Values.global -}}
  {{ $xrootd_mgmGlobal := dig "service" "xrootd_mgm" "port" "" .Values.global -}}
{{- end}}
{{- lower (coalesce $xrootd_mgmGlobal $xrootd_mgmLocal $xrootd_mgmDefault) }}
{{- end }}

{{- define "mgm.service.xrootd_sync.port" -}}
{{- $xrootd_syncDefault := 1096 -}}
{{- $xrootd_syncLocal := "" -}}
{{- $xrootd_syncGlobal := "" -}}
{{- if .Values.service -}}
  {{ $xrootd_syncLocal := dig "xrootd_sync" "port" "" .Values.service -}}
{{- end}}
{{- if .Values.global -}}
  {{ $xrootd_syncGlobal := dig "service" "xrootd_sync" "port" "" .Values.global -}}
{{- end}}
{{- lower (coalesce $xrootd_syncGlobal $xrootd_syncLocal $xrootd_syncDefault) }}
{{- end }}

{{- define "mgm.service.xrootd_http.port" -}}
{{- $xrootd_httpDefault := 8000 -}}
{{- $xrootd_httpLocal := "" -}}
{{- $xrootd_httpGlobal := "" -}}
{{- if .Values.service -}}
  {{ $xrootd_httpLocal := dig "xrootd_http" "port" "" .Values.service -}}
{{- end}}
{{- if .Values.global -}}
  {{ $xrootd_httpGlobal := dig "service" "xrootd_http" "port" "" .Values.global -}}
{{- end}}
{{- lower (coalesce $xrootd_httpGlobal $xrootd_httpLocal $xrootd_httpDefault) }}
{{- end }}

{{- define "mgm.service.fusex.port" -}}
{{- $fusexDefault := 1100 -}}
{{- $fusexLocal := "" -}}
{{- $fusexGlobal := "" -}}
{{- if .Values.service -}}
  {{ $fusexLocal := dig "fusex" "port" "" .Values.service -}}
{{- end}}
{{- if .Values.global -}}
  {{ $fusexGlobal := dig "service" "fusex" "port" "" .Values.global -}}
{{- end}}
{{- lower (coalesce $fusexGlobal $fusexLocal $fusexDefault) }}
{{- end }}

{{/*
StartupProbe definition
*/}}
{{- define "mgm.startupProbe" -}}
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
      {{- if .mgm.startupProbe.enabled }}
startupProbe:
  tcpSocket:
    host: {{ $.Release.Name }}-mgm
    port: {{ .service.xrootd_mq.port }}
  failureThreshold: {{ .mgm.startupProbe.failureThreshold }}
  periodSeconds: {{ .mgm.startupProbe.periodSeconds }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

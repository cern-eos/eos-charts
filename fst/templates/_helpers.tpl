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
{{- end}}
{{- if .Values.global -}}
  {{ $microhttpGlobal = dig "ports" "microhttp" "" .Values.global -}}
{{- end}}
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

{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "sps.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sps.fullname" -}}
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
{{- define "sps.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "sps.labels" -}}
helm.sh/chart: {{ include "sps.chart" . }}
{{ include "sps.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "sps.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sps.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "sps.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "sps.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Namespace definition
*/}}
{{- define "sps.namespace" -}}
{{- $namespace := default "default" .Values.namespace -}}
{{- if .Values.global -}}
    {{ dig "namespace" $namespace .Values.global }}
{{- else -}}
    {{ $namespace }}
{{- end }}
{{- end }}

{{/*
SPS network ports definition
  - xrootd sps port (defaults to 1095)

All the ports can be set according to (example for xrootd sps):
  - Global value '.Values.global.ports.xrootd_sps' (has the highest priority)
  - Local value '.Values.ports.xrootd_sps' (has lower priority)
  - Default value (shown above for each port)
*/}}
{{- define "sps.service.port.xrootd_sps" -}}
{{- $spsDefault := "1094" -}}
{{- $spsLocal := "" -}}
{{- $spsGlobal := "" -}}
{{- if .Values.ports -}}
  {{ $spsLocal = dig "xrootd_sps" "" .Values.ports -}}
{{- end }}
{{- if .Values.global -}}
  {{ $spsGlobal = dig "ports" "xrootd_sps" "" .Values.global -}}
{{- end }}
{{- coalesce $spsGlobal $spsLocal $spsDefault }}
{{- end }}

{{/*
MGM's FQDN definition.
  Define the value for environment variable EOS_MGM_URL.
  - It is mainly used by the initContainer to make sure the MGM is online before starting the proxy.
  - It is also set in the main proxy container for convenience while debugging

Returns:
  - The FQDN provided by utils.mgm_fqdn, if eosMgmUrlAuto is set;
  - The value manually defined in eosMgmUrl otherwise.

** This is copy-pasted from the fusex chart **

*/}}
{{- define "sps.eos_mgm_url" -}}
{{- if .Values.checkMgmOnline.eosMgmUrlAuto -}}
{{- printf "%s" ( include "utils.mgm_fqdn" . ) -}}
{{- else }}
{{- printf "%s" .Values.checkMgmOnline.eosMgmUrl -}}
{{- end }}
{{- end }}


{{/*
Liveness Probe definition
*/}}
{{- define "sps.livenessProbe" -}}
{{- $livenessEnabled := "true" -}}
{{- if .Values.probes -}}
  {{- $livenessEnabled = dig "liveness" $livenessEnabled .Values.probes -}}
{{- end }}
{{- if .Values.global -}}
  {{- $livenessEnabled = dig "probes" "sps_liveness" $livenessEnabled .Values.global }}
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
Name of the secret storing the SSS keytab for sps
Returns:
  - "<release_fullname>-sps.sss-keytab" when .Values.sps.keytab.value or .file are passed
  - the name of the secret passed as .Values.sps.keytab.secret
  - "<release_fullname>-sps.sss-keytab" by default.
If the secret does not exist, the pod will hang due to the missing mount.

** This is copy-pasted from the fusex chart **

*/}}
{{- define "sps.sssKeytabSecretName" -}}
{{- if or .Values.sps.keytab.value .Values.sps.keytab.file -}}
{{- printf "%s%s" (include "sps.fullname" .) "-sps.sss-keytab" }}
{{- else if .Values.sps.keytab.secret }}
{{- printf "%s" .Values.sps.keytab.secret }}
{{- else }}
{{- printf "%s%s" (include "sps.fullname" .) "-sps.sss-keytab" }}
{{- end }}
{{- end }}


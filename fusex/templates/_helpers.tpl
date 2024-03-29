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

{{/*
MGM's FQDN definition.
  Define the value for environment variable EOS_MGM_URL.
  - It is mainly used by the initContainer to make sure the MGM is online before starting the mount.
  - It is also set in the main fuxes container for convenience while debugging

Returns:
  - The FQDN provided by utils.mgm_fqdn, if eosMgmUrlAuto is set;
  - The value manually defined in eosMgmUrl otherwise.
*/}}
{{- define "fusex.eos_mgm_url" -}}
{{- if .Values.checkMgmOnline.eosMgmUrlAuto -}}
{{- printf "%s" ( include "utils.mgm_fqdn" . ) -}}
{{- else }}
{{- printf "%s" .Values.checkMgmOnline.eosMgmUrl -}}
{{- end }}
{{- end }}

{{/*
Liveness Probe definition
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
    - /bin/ps
    - -C
    - eosxd
  initialDelaySeconds: 5
  periodSeconds: 10
  successThreshold: 1
  failureThreshold: 3
{{- end }}
{{- end }}

{{/*
Name of the secret storing the SSS keytab for fusex
Returns:
  - "<release_fullname>-fusex-sss-keytab" when .Values.fusex.keytab.value or .file are passed
  - the name of the secret passed as .Values.fusex.keytab.secret
  - "<release_fullname>-fusex-sss-keytab" by default.
If the secret does not exist, the pod will hang due to the missing mount.
*/}}
{{- define "fusex.sssKeytabSecretName" -}}
{{- if or .Values.fusex.keytab.value .Values.fusex.keytab.file -}}
{{- printf "%s%s" (include "fusex.fullname" .) "-fusex-sss-keytab" }}
{{- else if .Values.fusex.keytab.secret }}
{{- printf "%s" .Values.fusex.keytab.secret }}
{{- else }}
{{- printf "%s%s" (include "fusex.fullname" .) "-fusex-sss-keytab" }}
{{- end }}
{{- end }}

{{/*
Name of the configMap storing the kerberos configuration for fusex
Returns:
  - "<release_fullname>-fusex-krb5-conf" when .Values.fusex.kerberos.clientConfig.file is passed
  - the name of the secret passed as .Values.fusex.kerberos.clientConfig.configMap
  - "<release_fullname>-fusex-krb5-conf" by default.
If the configMap does not exist, the pod will hang due to the missing mount.
*/}}
{{- define "fusex.krb5ConfConfigMapName" -}}
{{- if .Values.fusex.kerberos.clientConfig.file }}
{{- printf "%s%s" (include "fusex.fullname" .) "-fusex-krb5-conf" }}
{{- else if .Values.fusex.kerberos.clientConfig.configMap }}
{{- printf "%s" .Values.fusex.kerberos.clientConfig.configMap }}
{{- else }}
{{- printf "%s%s" (include "fusex.fullname" .) "-fusex-krb5-conf" }}
{{- end }}
{{- end }}

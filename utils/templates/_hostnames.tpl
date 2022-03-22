{{/*
QDB cluster hostname definition
  Used to set the hostname of the QDB cluster (short format).
  See MGM hostname definition for the details on the logic.
*/}}
{{- define "utils.qdbcluster_hostname" -}}
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
{{- define "utils.mgm_hostname" -}}
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
MGM FQDN definition
  Used to set environment variables, e.g., EOS_MGM_MASTER1/2, EOS_MGM_ALIAS, ...
*/}}
{{- define "utils.mgm_fqdn" -}}
{{- $mgmHostname := (include "utils.mgm_hostname" . ) -}}
{{ printf "%s-0.%s.%s.svc.%s" $mgmHostname $mgmHostname .Release.Namespace .Values.global.clusterDomain }}
{{- end }}


{{/*
MQ cluster hostname definition
  Used to set the hostname of the MQ (short format).
  See MGM hostname definition for the details on the logic.
*/}}
{{- define "utils.mq_hostname" -}}
{{- $mqDefault := "" -}}
{{- $mqLocal := "" -}}
{{- $mqGlobal := "" -}}
{{- if eq ( include "podSharing.mgmMq" . ) "true" }}
  {{- $mqDefault = printf "%s-mgm" .Release.Name -}}
{{- else -}}
  {{- $mqDefault = printf "%s-mq" .Release.Name -}}
{{- end -}}
{{- if .Values.hostnames -}}
  {{ $mqLocal = dig "mq" "" .Values.hostnames }}
{{- end }}
{{- if .Values.global -}}
  {{- $mqGlobal = dig "hostnames" "mq" "" .Values.global -}}
{{- end }}
{{- coalesce $mqGlobal $mqLocal $mqDefault }}
{{- end }}


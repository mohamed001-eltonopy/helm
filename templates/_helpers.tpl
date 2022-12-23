{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "DXLchart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "DXLchart.fullname" -}}
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
{{- define "DXLchart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "DXLchart.labels" -}}
app.kubernetes.io/instana: {{ (split ":" .Values.image.name)._1 | quote }}
helm.sh/chart: {{ include "DXLchart.chart" . }}
{{ include "DXLchart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "DXLchart.governanceLabels" . }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "DXLchart.selectorLabels" -}}
app.kubernetes.io/name: {{ include "DXLchart.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "DXLchart.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "DXLchart.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Governance labels
*/}}
{{- define "DXLchart.governanceLabels" -}}
{{- with .Values.microservice }}
microservice.type: {{ .type | squote }}
{{- end }}
contact.productowner: {{ .Values.productOwner.email | replace "@" "_at_" | squote }}
contact.team: {{ .Values.team.email | replace "@" "_at_" | squote }}
contact.deployment: {{ .Values.governance.deployer | replace "@" "_at_" | squote }}
environment.type: {{ .Values.governance.environment.name | squote }}
environment.down: {{ .Values.governance.environment.down | squote }}
environment.up: {{ .Values.governance.environment.up | squote }}
microservice.localmarket: {{ .Values.governance.environment.market | squote }}
{{- end -}}

{{/*
Governance annotations
*/}}
{{- define "DXLchart.governanceAnnotations" -}}
contact.support: {{ .Values.team.phone | squote }}
microservice.name: {{ .Values.nameOverride | replace "-" "_" | squote }}
microservice.repository: {{ .Values.governance.repository | squote }}
microservice.documentation: {{ .Values.governance.documentation | default .Values.governance.repository | squote }}
{{- end -}}

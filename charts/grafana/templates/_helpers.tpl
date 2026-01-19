{{/*
Expand the name of the chart.
*/}}
{{- define "grafana.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "grafana.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "grafana.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "grafana.labels" -}}
helm.sh/chart: {{ include "grafana.chart" . }}
{{ include "grafana.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "grafana.selectorLabels" -}}
app.kubernetes.io/name: {{ include "grafana.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Generate OIDC configuration for grafana.ini
*/}}
{{- define "grafana.oidcConfig" -}}
{{- if .Values.oidc.enabled }}
auth:
  generic_oauth:
    enabled: true
    name: {{ .Values.oidc.name | quote }}
    client_id: {{ .Values.oidc.clientId | quote }}
    {{- if .Values.oidc.clientSecret }}
    client_secret: {{ .Values.oidc.clientSecret | quote }}
    {{- end }}
    scopes: {{ .Values.oidc.scopes | join "," | quote }}
    auth_url: {{ printf "%s/authorize" .Values.oidc.issuer | quote }}
    token_url: {{ printf "%s/oauth2/token" .Values.oidc.issuer | quote }}
    api_url: {{ printf "%s/userinfo" .Values.oidc.issuer | quote }}
    {{- if .Values.oidc.roleAttributePath }}
    role_attribute_path: {{ .Values.oidc.roleAttributePath | quote }}
    {{- end }}
    {{- if .Values.oidc.groupAttributePath }}
    groups_attribute_path: {{ .Values.oidc.groupAttributePath | quote }}
    {{- end }}
    {{- if .Values.oidc.logoutUrl }}
    auth_url_logout: {{ .Values.oidc.logoutUrl | quote }}
    {{- end }}
    allow_sign_up: true
    use_pkce: true
{{- end }}
{{- end }}

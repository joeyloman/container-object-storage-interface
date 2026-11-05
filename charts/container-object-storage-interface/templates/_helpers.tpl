{{/*
Chart name, overridable via nameOverride.
*/}}
{{- define "cosi.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified app name, overridable via fullnameOverride.
*/}}
{{- define "cosi.fullname" -}}
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
Chart label value.
*/}}
{{- define "cosi.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "cosi.labels" -}}
helm.sh/chart: {{ include "cosi.chart" . }}
{{ include "cosi.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: container-object-storage-interface
app.kubernetes.io/component: controller
{{- end }}

{{/*
Selector labels. These are immutable for a Deployment.
*/}}
{{- define "cosi.selectorLabels" -}}
app.kubernetes.io/name: {{ include "cosi.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ServiceAccount name.
*/}}
{{- define "cosi.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "cosi.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Controller image reference.
*/}}
{{- define "cosi.image" -}}
{{- printf "%s:%s" .Values.image.repository (toString .Values.image.tag) }}
{{- end }}

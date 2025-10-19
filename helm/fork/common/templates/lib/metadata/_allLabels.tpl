{{/* Common labels shared across objects */}}
{{- define "common.lib.metadata.allLabels" -}}
helm.sh/chart: {{ include "common.lib.chart.names.chart" . }}
{{ include "common.lib.metadata.selectorLabels" . }}
  {{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
  {{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "common.lib.metadata.globalLabels" . }}
{{- end -}}

{{/* Selector labels shared across objects */}}
{{- define "common.lib.metadata.selectorLabels" -}}
app.kubernetes.io/name: {{ include "common.lib.chart.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/* Selector labels shared across objects */}}
{{- define "umbrella.lib.metadata.selectorLabels" -}}
app.kubernetes.io/name: {{ include "umbrella.lib.chart.names.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: {{ include "umbrella.lib.chart.names.name" . }}
{{- end -}}

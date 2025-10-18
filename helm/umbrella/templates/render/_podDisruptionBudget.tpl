{{/*
Renders the PodDisruptionBudget object required by the chart.
*/}}
{{- define "umbrella.render.podDisruptionBudget" -}}
  {{- if .Values.podDisruptionBudget.enabled -}}
    {{- /* Create a podDisruptionBudget */ -}}
    {{- $podDisruptionBudgetName := include "umbrella.lib.chart.names.fullname" . -}}

    {{- include "umbrella.class.podDisruptionBudget" $ | nindent 0 -}}
  {{- end -}}
{{- end -}}

{{/*
Renders the podDisruptionBudget objects required by the chart.
*/}}
{{- define "common.render.podDisruptionBudget" -}}
  {{- $rootContext := $ -}}
  {{- if $rootContext.Values.podDisruptionBudget.enabled }}
    {{- include "common.class.podDisruptionBudget" (dict "rootContext" $rootContext) | nindent 0 -}}
  {{- end }}
{{- end -}}

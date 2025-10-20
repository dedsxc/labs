{{/*
Renders the podDisruptionBudget objects required by the chart.
*/}}
{{- define "common.render.podDisruptionBudget" -}}
  {{- $rootContext := $ -}}
  {{- range $key, $values := .Values.podDisruptionBudget }}
    {{- if $values.enabled -}}
      {{- $values := (include "common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $key "values" $values) | fromYaml) -}}
      {{- include "common.class.podDisruptionBudget" (dict "rootContext" $rootContext "object" $values) | nindent 0 -}}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
Renders the externalSecret objects required by the chart.
*/}}
{{- define "common.render.externalSecrets" -}}
  {{- $rootContext := $ -}}
  {{- range $key, $values := $rootContext.Values.externalSecret }}
    {{- if $values.enabled -}}
      {{- $externalSecretObject := (include "common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $key "values" $values) | fromYaml) -}}
      {{- include "common.class.externalSecret" (dict "rootContext" $rootContext "object" $externalSecretObject) | nindent 0 -}}
    {{- end }}
  {{- end }}
{{- end -}}

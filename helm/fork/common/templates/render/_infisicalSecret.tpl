{{/*
Renders the infisicalSecret objects required by the chart.
*/}}
{{- define "common.render.infisicalSecrets" -}}
  {{- $rootContext := $ -}}
  {{- range $key, $values := $rootContext.Values.infisicalSecret }}
    {{- if $values.enabled -}}
      {{- $infisicalSecretObject := (include "common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $key "values" $values) | fromYaml) -}}
      {{- include "common.class.infisicalSecret" (dict "rootContext" $rootContext "object" $infisicalSecretObject) | nindent 0 -}}
    {{- end }}
  {{- end }}
{{- end -}}

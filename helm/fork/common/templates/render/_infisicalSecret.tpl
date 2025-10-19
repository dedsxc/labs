{{/*
Renders the infisicalSecret objects required by the chart.
*/}}
{{- define "common.render.infisicalSecrets" -}}
  {{- $rootContext := $ -}}
  {{- range $name, $infisicalSecret := .Values.infisicalSecret }}
    {{- if $infisicalSecret.enabled -}}
      {{- $infisicalSecretObject := (include "common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $name "values" $infisicalSecret) | fromYaml) -}}
      {{- include "common.class.infisicalSecret" (dict "rootContext" $rootContext "object" $infisicalSecretObject) | nindent 0 -}}
    {{- end }}
  {{- end }}
{{- end -}}

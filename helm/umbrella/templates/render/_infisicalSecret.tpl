{{/*
Renders the infisicalSecret objects required by the chart.
*/}}
{{- define "umbrella.render.infisicalSecrets" -}}
  {{- /* Generate named infisicalSecret as required */ -}}
  {{- range $name, $infisicalSecret := .Values.infisicalSecret }}
    {{- if $infisicalSecret.enabled -}}
      {{- $infisicalSecretValues := $infisicalSecret -}}

      {{/* set the default nameOverride to the infisicalSecret name */}}
      {{- if not $infisicalSecretValues.nameOverride -}}
        {{- $_ := set $infisicalSecretValues "nameOverride" $name -}}
      {{ end -}}

      {{- $_ := set $ "ObjectValues" (dict "infisicalSecret" $infisicalSecretValues) -}}
      {{- include "umbrella.class.infisicalSecret" $ | nindent 0 -}}
    {{- end }}
  {{- end }}
{{- end }}

{{/*
Renders the externalSecret objects required by the chart.
*/}}
{{- define "umbrella.render.externalSecrets" -}}
  {{- /* Generate named externalSecret as required */ -}}
  {{- range $name, $externalSecret := .Values.externalSecret }}
    {{- if $externalSecret.enabled -}}
      {{- $externalSecretValues := $externalSecret -}}

      {{/* set the default nameOverride to the externalSecret name */}}
      {{- if not $externalSecretValues.nameOverride -}}
        {{- $_ := set $externalSecretValues "nameOverride" $name -}}
      {{ end -}}

      {{- $_ := set $ "ObjectValues" (dict "externalSecret" $externalSecretValues) -}}
      {{- include "umbrella.class.externalSecret" $ | nindent 0 -}}
    {{- end }}
  {{- end }}
{{- end }}

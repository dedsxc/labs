{{/*
Renders the Argo Rollout Service objects required by the chart.
*/}}
{{- define "umbrella.render.argoRolloutService" -}}
{{- if eq .Values.controller.type "argorollout" -}}
  {{/* Generate named services as required */}}
  {{- range $name, $service := .Values.service -}}
    {{- $serviceEnabled := true -}}
    {{- if hasKey $service "enabled" -}}
      {{- $serviceEnabled = $service.enabled -}}
    {{- end -}}
    {{- if $serviceEnabled -}}
      {{- $serviceValues := $service -}}

      {{/* set the default nameOverride to the service name */}}
      {{- if and (not $serviceValues.nameOverride) (ne $name (include "umbrella.lib.service.primary" $)) -}}
        {{- $_ := set $serviceValues "nameOverride" $name -}}
      {{ end -}}

      {{/* Include the Service class */}}
      {{- $_ := set $ "ObjectValues" (dict "service" $serviceValues) -}}
      {{- include "umbrella.class.argoRolloutService" $ | nindent 0 -}}
      {{- $_ := unset $.ObjectValues "service" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
{{- end -}}

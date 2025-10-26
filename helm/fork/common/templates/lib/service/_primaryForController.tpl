{{/*
Return the primary service object for a controller
*/}}
{{- define "common.lib.service.primaryForController" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledServices := (include "common.lib.service.enabledServices" (dict "rootContext" $rootContext) | fromYaml ) }}
  {{- if $enabledServices -}}
    {{- $primaryIdentifier := "" -}}
    {{- range $identifier, $service := $enabledServices -}}
      {{- if (hasKey $service "primary") -}}
        {{- if $service.primary -}}
          {{- $primaryIdentifier = $identifier -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}

    {{- if $primaryIdentifier -}}
      {{- include "common.lib.service.getByIdentifier" (dict "rootContext" $rootContext "id" $primaryIdentifier) -}}
    {{- else -}}
      {{- $fallback := (keys $enabledServices | sortAlpha | first) -}}
      {{- include "common.lib.service.getByIdentifier" (dict "rootContext" $rootContext "id" $fallback) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{/*
Return an Ingress Object by its Identifier.
*/}}
{{- define "common.lib.ingress.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}

  {{- $enabledIngresses := (include "common.lib.ingress.enabledIngresses" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledIngresses $identifier) -}}
    {{- get $enabledIngresses $identifier | toYaml -}}
  {{- end -}}
{{- end -}}

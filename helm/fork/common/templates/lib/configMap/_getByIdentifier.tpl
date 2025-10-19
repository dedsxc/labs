{{/*
Return a configMap Object by its Identifier.
*/}}
{{- define "common.lib.configMap.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledConfigMaps := (include "common.lib.configMap.enabledConfigmaps" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledConfigMaps $identifier) -}}
    {{- $objectValues := get $enabledConfigMaps $identifier -}}
    {{- include "common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledConfigMaps)) -}}
  {{- end -}}
{{- end -}}

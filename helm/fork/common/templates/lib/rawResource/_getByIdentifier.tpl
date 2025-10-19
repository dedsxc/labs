{{/*
Return a RawResource Object by its Identifier.
*/}}
{{- define "common.lib.rawResource.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledRawResources := (include "common.lib.rawResource.enabledRawResources" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledRawResources $identifier) -}}
    {{- $objectValues := get $enabledRawResources $identifier -}}
    {{- include "common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledRawResources)) -}}
  {{- end -}}
{{- end -}}

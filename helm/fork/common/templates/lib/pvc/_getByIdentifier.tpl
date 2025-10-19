{{/*
Return a PVC object by its Identifier.
*/}}
{{- define "common.lib.pvc.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledPVCs := (include "common.lib.pvc.enabledPVCs" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledPVCs $identifier) -}}
    {{- $objectValues := get $enabledPVCs $identifier -}}
    {{- include "common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledPVCs)) -}}
  {{- end -}}
{{- end -}}

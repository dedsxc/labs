{{- define "common.lib.controller.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledControllers := (include "common.lib.controller.enabledControllers" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- include "common.lib.valuesToObject" (dict "rootContext" $rootContext "id" "main" "values" $enabledControllers.controller "itemCount" 1) -}}
{{- end -}}

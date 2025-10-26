{{- define "common.lib.controller.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $controller := (include "common.lib.controller.enabledControllers" (dict "rootContext" $rootContext) | fromYaml ) }}
  {{- include "common.lib.valuesToObject" (dict "rootContext" $rootContext "id" "main" "values" $controller "itemCount" 1) -}}
{{- end -}}

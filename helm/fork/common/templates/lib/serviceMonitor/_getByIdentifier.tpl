{{/*
Return a ServiceMonitor Object by its Identifier.
*/}}
{{- define "common.lib.serviceMonitor.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledServiceMonitors := (include "common.lib.serviceMonitor.enabledServiceMonitors" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledServiceMonitors $identifier) -}}
    {{- $objectValues := get $enabledServiceMonitors $identifier -}}
    {{- include "common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledServiceMonitors)) -}}
  {{- end -}}
{{- end -}}

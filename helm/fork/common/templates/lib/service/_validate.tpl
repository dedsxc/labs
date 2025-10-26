{{/*
Validate Service values
*/}}
{{- define "common.lib.service.validate" -}}
  {{- $rootContext := .rootContext -}}
  {{- $serviceObject := .object -}}

  {{- $enabledControllers := (include "common.lib.controller.enabledControllers" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- $enabledPorts := include "common.lib.service.enabledPorts" (dict "rootContext" $rootContext "serviceObject" $serviceObject) | fromYaml }}

  {{- $serviceController := include "common.lib.controller.getByIdentifier" (dict "rootContext" $rootContext "id" $serviceObject.controller) -}}
  {{- if empty $serviceController -}}
    {{- fail (printf "No enabled controller found with this identifier. (service: '%s', controller: '%s')" $serviceObject.identifier $serviceObject.controller) -}}
  {{- end -}}

  {{- /* Validate Service type */ -}}
  {{- $validServiceTypes := (list "ClusterIP" "LoadBalancer" "NodePort" "ExternalName" "ExternalIP") -}}
  {{- if and $serviceObject.type (not (mustHas $serviceObject.type $validServiceTypes)) -}}
    {{- fail (
      printf "invalid service type \"%s\" for Service with key \"%s\". Allowed values are [%s]"
      $serviceObject.type
      $serviceObject.identifier
      (join ", " $validServiceTypes)
    ) -}}
  {{- end -}}

  {{- if ne $serviceObject.type "ExternalName" -}}
    {{- $enabledPorts := include "common.lib.service.enabledPorts" (dict "rootContext" $rootContext "serviceObject" $serviceObject) | fromYaml }}
    {{- /* Validate at least one port is enabled */ -}}
    {{- if not $enabledPorts -}}
      {{- fail (printf "No ports are enabled for Service with this identifier. (service: '%s')" $serviceObject.identifier) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

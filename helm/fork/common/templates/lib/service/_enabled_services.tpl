{{/*
Return the enabled services.
*/}}
{{- define "common.lib.service.enabledServices" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledServices := dict -}}

  {{- range $identifier, $objectValues := $rootContext.Values.service -}}
    {{- if kindIs "map" $objectValues -}}
      {{- /* Enable Service by default, but allow override */ -}}
      {{- $serviceEnabled := true -}}
      {{- if hasKey $objectValues "enabled" -}}
        {{- $serviceEnabled = $objectValues.enabled -}}
      {{- end -}}

      {{- if $serviceEnabled -}}
        {{- $_ := set $enabledServices $identifier $objectValues -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- range $identifier, $objectValues := $enabledServices -}}
    {{- $object := include "common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledServices)) | fromYaml -}}
    {{- $_ := set $enabledServices $identifier $object -}}
  {{- end -}}

  {{- $enabledServices | toYaml -}}
{{- end -}}

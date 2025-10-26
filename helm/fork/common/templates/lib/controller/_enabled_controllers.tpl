{{/*
Return the single controller if enabled.
*/}}
{{- define "common.lib.controller.enabledControllers" -}}
  {{- $rootContext := .rootContext -}}
  {{- $controller := $rootContext.Values.controller | default dict -}}
  {{- $enabledControllers := dict -}}

  {{- $controllerEnabled := true -}}
  {{- if hasKey $controller "enabled" -}}
    {{- $controllerEnabled = $controller.enabled -}}
  {{- end -}}

  {{- if $controllerEnabled -}}
    {{- $_ := set $enabledControllers "controller" $controller -}}
  {{- end -}}

  {{- $enabledControllers | toYaml -}}
{{- end -}}

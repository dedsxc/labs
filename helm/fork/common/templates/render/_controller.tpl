{{/*
Renders the controller objects required by the chart.
*/}}
{{- define "common.render.controller" -}}
  {{- $rootContext := $ -}}
  {{- $controller := $rootContext.Values.controller | default dict -}}
  {{- if not $controller.type -}}
    {{-   fail "❌  .Values.controller.type is required" -}}
  {{- end -}}
  
  {{- if eq $controller.type "deployment" -}}
    {{- include "common.class.deployment" $rootContext -}}
  {{- else if eq $controller.type "statefulset" -}}
    {{- include "common.class.statefulset" $rootContext -}}
  {{- end -}}
{{- end -}}


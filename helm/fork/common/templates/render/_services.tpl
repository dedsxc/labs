{{/*
Renders the Service objects required by the chart.
*/}}
{{- define "common.render.services" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate named Services as required */ -}}
  {{- $enabledServices := (include "common.lib.service.enabledServices" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledServices -}}
    {{- /* Generate object from the raw service values */ -}}
    {{- $serviceObject := (include "common.lib.service.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Include the Service class */ -}}
    {{- include "common.class.service" (dict "rootContext" $rootContext "object" $serviceObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}

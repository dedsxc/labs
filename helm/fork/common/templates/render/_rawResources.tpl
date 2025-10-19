{{/*
Renders other arbirtrary objects required by the chart.
*/}}
{{- define "common.render.rawResources" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate raw resources as required */ -}}
  {{- $enabledRawResources := (include "common.lib.rawResource.enabledRawResources" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledRawResources -}}
    {{- /* Generate object from the raw resource values */ -}}
    {{- $rawResourceObject := (include "common.lib.rawResource.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Include the raw resource class */ -}}
    {{- include "common.class.rawResource" (dict "rootContext" $rootContext "object" $rawResourceObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}

{{/*
Renders the Route objects required by the chart
*/}}
{{- define "common.render.routes" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate named routes as required */ -}}
  {{- $enabledRoutes := (include "common.lib.route.enabledRoutes" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledRoutes -}}
    {{- /* Generate object from the raw route values */ -}}
    {{- $routeObject := (include "common.lib.route.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Perform validations on the Route before rendering */ -}}
    {{- include "common.lib.route.validate" (dict "rootContext" $rootContext "object" $routeObject) -}}

    {{- /* Include the Route class */ -}}
    {{- include "common.class.route" (dict "rootContext" $rootContext "object" $routeObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}

{{/*
Image used by the container.
*/}}
{{- define "common.lib.container.field.image" -}}
  {{- $ctx := .ctx -}}
  {{- $rootContext := $ctx.rootContext -}}
  {{- $containerObject := $ctx.containerObject -}}

  {{- include "common.lib.imageSpecificationToImage" (dict "rootContext" $rootContext "imageSpec" $containerObject.image) -}}
{{- end -}}

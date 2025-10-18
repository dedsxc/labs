{{/*
Main entrypoint for the umbrella chart. It will render all underlying templates based on the provided values.
*/}}
{{- define "umbrella.loader.all" -}}
  {{- /* Generate chart and dependency values */ -}}
  {{- include "umbrella.loader.init" . -}}

  {{- /* Generate remaining objects */ -}}
  {{- include "umbrella.loader.generate" . -}}
{{- end -}}

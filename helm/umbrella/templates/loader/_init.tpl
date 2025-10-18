{{- define "umbrella.loader.init" -}}
  {{- /* Merge the local chart values and the common chart defaults */ -}}
  {{- include "umbrella.values.init" . }}
{{- end -}}

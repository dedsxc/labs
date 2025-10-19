{{- define "common.loader.init" -}}
  {{- /* Merge the local chart values and the common chart defaults */ -}}
  {{- include "common.values.init" . }}
{{- end -}}

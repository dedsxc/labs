{{/*
Convert DaemonSet values to an object
*/}}
{{- define "common.lib.daemonset.valuesToObject" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $objectValues := .values -}}

  {{- /* Return the DaemonSet object */ -}}
  {{- $objectValues | toYaml -}}
{{- end -}}

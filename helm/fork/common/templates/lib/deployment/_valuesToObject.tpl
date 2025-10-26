{{/*
Convert Deployment values to an object
*/}}
{{- define "common.lib.deployment.valuesToObject" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $objectValues := .values -}}

  {{- $strategy := default "RollingUpdate" $objectValues.strategy -}}
  {{- $_ := set $objectValues "strategy" $strategy -}}

  {{- /* Return the Deployment object */ -}}
  {{- $objectValues | toYaml -}}
{{- end -}}

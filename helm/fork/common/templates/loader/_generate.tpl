{{/*
Secondary entrypoint and primary loader for the common chart
*/}}
{{- define "common.loader.generate" -}}
  {{- $rootContext := $ -}}
  {{- $mergedValues := tpl (deepCopy .Values | toYaml) . | fromYaml -}}
  {{- $_ := set . "Values" $mergedValues -}}

  {{- /* Run global chart validations */ -}}
  {{- include "common.lib.chart.validate" $rootContext -}}

  {{- /* Build the templates */ -}}
  {{- include "common.render.controllers" $rootContext | nindent 0 -}}
  {{- include "common.render.configMaps" $rootContext | nindent 0 -}}
  {{- include "common.render.configMaps.fromFolder" $rootContext | nindent 0 -}}
  {{- include "common.render.externalSecrets" $rootContext | nindent 0 -}}
  {{- include "common.render.infisicalSecrets" $rootContext | nindent 0 -}}
  {{- include "common.render.ingresses" $rootContext | nindent 0 -}}
  {{- include "common.render.networkpolicies" $rootContext | nindent 0 -}}
  {{- include "common.render.podDisruptionBudget" $rootContext | nindent 0 -}}
  {{- include "common.render.pvcs" $rootContext | nindent 0 -}}
  {{- include "common.render.rbac" $rootContext | nindent 0 -}}
  {{- include "common.render.rawResources" $rootContext | nindent 0 -}}
  {{- include "common.render.routes" $rootContext | nindent 0 -}}
  {{- include "common.render.serviceAccount" $rootContext | nindent 0 -}}
  {{- include "common.render.serviceMonitors" $rootContext | nindent 0 -}}
  {{- include "common.render.services" $rootContext | nindent 0 -}}
  {{- include "common.render.secrets" $rootContext | nindent 0 -}}
  {{- include "common.render.secrets.fromFolder" $rootContext | nindent 0 -}}
{{- end -}}

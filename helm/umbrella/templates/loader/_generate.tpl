{{/*
Secondary entrypoint and primary loader for the common chart
*/}}
{{- define "umbrella.loader.generate" -}}
  {{- $mergedValues := tpl (deepCopy .Values | toYaml) . | fromYaml -}}
  {{- $_ := set . "Values" $mergedValues -}}

  {{- /* Build the templates */ -}}
  {{- include "umbrella.render.argoRolloutService" . | nindent 0 -}}
  {{- include "umbrella.render.ciliumNetworkPolicies" . | nindent 0 -}}
  {{- include "umbrella.render.configmaps" . | nindent 0 -}}
  {{- include "umbrella.render.controller" . | nindent 0 -}}
  {{- include "umbrella.render.externalSecrets" . | nindent 0 -}}
  {{- include "umbrella.render.horizontalPodAutoscaler" . | nindent 0 -}}
  {{- include "umbrella.render.ingresses" . | nindent 0 -}}
  {{- include "umbrella.render.infisicalSecrets" . | nindent 0 -}}
  {{- include "umbrella.render.podDisruptionBudget" . | nindent 0 -}}
  {{- include "umbrella.render.pvs" . | nindent 0 -}}
  {{- include "umbrella.render.pvcs" . | nindent 0 -}}
  {{- include "umbrella.render.secrets" . | nindent 0 -}}
  {{- include "umbrella.render.services" . | nindent 0 -}}
  {{- include "umbrella.render.serviceAccount" . | nindent 0 -}}
  {{- include "umbrella.render.serviceMonitors" . | nindent 0 -}}  
{{- end -}}

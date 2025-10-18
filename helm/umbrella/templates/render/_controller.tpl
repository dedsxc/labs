{{/*
Renders the controller object required by the chart.
*/}}
{{- define "umbrella.render.controller" -}}
  {{- if .Values.controller.enabled -}}
    {{- if eq .Values.controller.type "deployment" -}}
      {{- include "umbrella.class.deployment" . | nindent 0 -}}
    {{- else if eq .Values.controller.type "cronjob" -}}
      {{- include "umbrella.class.cronjob" . | nindent 0 -}}
    {{ else if eq .Values.controller.type "daemonset" -}}
      {{- include "umbrella.class.daemonset" . | nindent 0 -}}
    {{ else if eq .Values.controller.type "statefulset"  -}}
      {{- include "umbrella.class.statefulset" . | nindent 0 -}}
    {{ else if eq .Values.controller.type "argorollout"  -}}
      {{- include "umbrella.class.argorollout" . | nindent 0 -}}
    {{ else -}}
      {{- fail (printf "Not a valid controller.type (%s)" .Values.controller.type) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

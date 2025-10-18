{{/*
Renders the HorizontalPodAutoscaler object required by the chart.
*/}}
{{- define "umbrella.render.horizontalPodAutoscaler" -}}
  {{- if .Values.horizontalPodAutoscaler.create -}}
    {{- /* Create an HorizontalPodAutoscaler */ -}}
    {{- include "umbrella.class.horizontalPodAutoscaler" $ | nindent 0 -}}
  {{- end -}}
{{- end -}}

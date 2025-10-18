{{/*
This template serves as a blueprint for HorizontalPodAutoscaler objects that are created
using the common library.
*/}}
{{- define "umbrella.class.horizontalPodAutoscaler" -}}
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "umbrella.lib.chart.names.horizontalPodAutoscalerName" . }}
  {{- with include "umbrella.lib.metadata.allLabels" $ | fromYaml }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with (merge (.Values.horizontalPodAutoscaler.annotations | default dict) (include "umbrella.lib.metadata.globalAnnotations" $ | fromYaml)) }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  scaleTargetRef: {{ include "umbrella.lib.controller.targetRef" . | nindent 4 }}
  minReplicas: {{ .Values.horizontalPodAutoscaler.minReplicas }}
  maxReplicas: {{ .Values.horizontalPodAutoscaler.maxReplicas }}
  metrics: {{ toYaml .Values.horizontalPodAutoscaler.metrics | nindent 4 }}
{{- end -}}

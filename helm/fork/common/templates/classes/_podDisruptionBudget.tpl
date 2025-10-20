{{/*
This template serves as a blueprint for PodDisruptionBudget objects that are created
using the common library.
*/}}
{{- define "common.class.podDisruptionBudget" -}}
  {{- $rootContext := .rootContext -}}

  {{- $labels := merge
    ($rootContext.Values.podDisruptionBudget.labels | default dict)
    (include "common.lib.metadata.allLabels" $rootContext | fromYaml)
  -}}
  {{- $annotations := merge
    ($rootContext.Values.podDisruptionBudget.annotations | default dict)
    (include "common.lib.metadata.globalAnnotations" $rootContext | fromYaml)
  -}}
---
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: {{ include "common.lib.chart.names.fullname" $rootContext }}
  {{- with $labels }}
  labels:
    {{- range $key, $value := . }}
      {{- printf "%s: %s" $key (tpl $value $rootContext | toYaml ) | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with $annotations }}
  annotations:
    {{- range $key, $value := . }}
      {{- printf "%s: %s" $key (tpl $value $rootContext | toYaml ) | nindent 4 }}
    {{- end }}
  {{- end }}
spec:
  {{- if $rootContext.Values.podDisruptionBudget.minAvailable }}
  minAvailable: {{ $rootContext.Values.podDisruptionBudget.minAvailable }}
  {{- else if $rootContext.Values.podDisruptionBudget.maxUnavailable }}
  maxUnavailable: {{ $rootContext.Values.podDisruptionBudget.maxUnavailable }}
  {{- end }}
  selector:
    matchLabels:
    {{- if $rootContext.Values.podDisruptionBudget.selector }}
      {{- with $rootContext.Values.podDisruptionBudget.selector }}
      {{- toYaml . | nindent 6 }}
      {{- end }}
    {{- else }}
      {{- with (merge
        (dict "app.kubernetes.io/controller" $rootContext.Values.podDisruptionBudget.controller)
        (include "common.lib.metadata.selectorLabels" $rootContext | fromYaml)
        (dict "app.kubernetes.io/name" (include "common.lib.chart.names.fullname" $rootContext))
      ) }}
      {{- toYaml . | nindent 6 }}
      {{- end }}
    {{- end }}
{{- end -}}

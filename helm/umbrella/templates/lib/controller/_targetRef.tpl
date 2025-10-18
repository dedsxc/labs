{{- /*
The apiVersion used in the controller
*/ -}}
{{- define "umbrella.lib.controller.apiVersion" -}}
  {{- if eq .Values.controller.type "cronjob" -}}
    batch/v1
  {{- else -}}
    apps/v1
  {{- end -}}
{{- end -}}
{{- /*
The kind used in the controller
*/ -}}
{{- define "umbrella.lib.controller.kind" -}}
  {{- if eq .Values.controller.type "deployment" -}}
    Deployment
  {{- else if eq .Values.controller.type "cronjob" -}}
    CronJob
  {{ else if eq .Values.controller.type "daemonset" -}}
    DeamonSet
  {{ else if eq .Values.controller.type "statefulset"  -}}
    StatefulSet
  {{ else -}}
    {{- fail (printf "Not a valid controller.type (%s)" .Values.controller.type) -}}
  {{- end -}}
{{- end -}}

{{- /*
The targetRef pointing to the controller
*/ -}}
{{- define "umbrella.lib.controller.targetRef" -}}
apiVersion: {{ include "umbrella.lib.controller.apiVersion" . }}
kind: {{ include "umbrella.lib.controller.kind" . }}
name: {{ include "umbrella.lib.chart.names.fullname" . }}
{{- end -}}

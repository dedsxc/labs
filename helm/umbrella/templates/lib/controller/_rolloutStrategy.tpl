{{- /*
The strategy definition included in the controller for Argo Rollout.
*/ -}}
{{- define "umbrella.lib.controller.rolloutStrategy" -}}
{{- if eq .Values.controller.rollout.strategy "bluegreen" -}}
blueGreen:
  {{- toYaml .Values.controller.rollout.config | nindent 2 }}
{{- else if eq .Values.controller.rollout.strategy "canary" -}}
canary:
  {{- toYaml .Values.controller.rollout.config | nindent 2 }}
{{- end -}}
{{- end -}}
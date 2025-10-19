{{/*
This template serves as a blueprint for all Secret objects that are created
within the common library.
*/}}
{{- define "common.class.secret" -}}
  {{- $rootContext := .rootContext -}}
  {{- $secretObject := .object -}}
  {{- $stringData := "" -}}
  {{- with $secretObject.stringData -}}
    {{- $stringData = (toYaml $secretObject.stringData) | trim -}}
  {{- end -}}
---
apiVersion: v1
kind: Secret
{{- with $secretObject.type }}
type: {{ . }}
{{- end }}
metadata:
  name: {{ $secretObject.name }}
  {{- with include "common.lib.controller.metadata.labels" $rootContext }}
  labels: {{- . | nindent 4 }}
  {{- end }}
  {{- with include "common.lib.controller.metadata.annotations" $rootContext }}
  annotations: {{- . | nindent 4 }}
  {{- end }}
  namespace: {{ $rootContext.Release.Namespace }}
{{- with $stringData }}
stringData: {{- . | nindent 2 }}
{{- end }}
{{- end -}}

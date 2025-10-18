{{/*
This template serves as a blueprint for all Secret objects that are created
within the common library.
*/}}
{{- define "umbrella.class.secret" -}}
  {{- $fullName := include "umbrella.lib.chart.names.fullname" . -}}
  {{- $secretName := $fullName -}}
  {{- $values := .Values.configmap -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.secret -}}
      {{- $values = . -}}
    {{- end -}}
  {{ end -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $secretName = printf "%v-%v" $secretName $values.nameOverride -}}
  {{- end }}
---
apiVersion: v1
kind: Secret
{{- with $values.type }}
type: {{ . }}
{{- end }}
metadata:
  name: {{ $secretName }}
  {{- with (merge ($values.labels | default dict) (include "umbrella.lib.metadata.allLabels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with (merge ($values.annotations | default dict) (include "umbrella.lib.metadata.globalAnnotations" $ | fromYaml)) }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
{{- with $values.stringData }}
stringData:
  {{- tpl (toYaml .) $ | nindent 2 }}
{{- end }}
{{- end -}}

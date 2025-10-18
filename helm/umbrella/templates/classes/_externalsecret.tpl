{{/*
This template serves as a blueprint for all Secret objects that are created
within the common library.
*/}}
{{- define "umbrella.class.externalSecret" -}}
  {{- $fullName := include "umbrella.lib.chart.names.fullname" . -}}
  {{- $externalSecretName := $fullName -}}
  {{- $values := .Values.externalSecret -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.externalSecret -}}
      {{- $values = . -}}
    {{- end -}}
  {{ end -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $externalSecretName = printf "%v-%v" $externalSecretName $values.nameOverride -}}
  {{- end }}
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
{{- with $values.type }}
type: {{ . }}
{{- end }}
metadata:
  name: {{ $externalSecretName }}
  {{- with (merge ($values.labels | default dict) (include "umbrella.lib.metadata.allLabels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with (merge ($values.annotations | default dict) (include "umbrella.lib.metadata.globalAnnotations" $ | fromYaml)) }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if $values.secretStoreRef }}
  secretStoreRef:
    name: {{ $values.secretStoreRef.name }}
    kind: {{ $values.secretStoreRef.kind }}
  {{- end }}
  refreshInterval: {{ $values.refreshInterval | default "1h"}}
  {{- if $values.target}}
  target:
    {{- tpl (toYaml $values.target) $ | nindent 4 }}
  {{- else }}
  target:
    name: {{ $externalSecretName }}
  {{- end }}
  {{- if $values.data }}
  data:
    {{- tpl (toYaml $values.data) $ | nindent 4 }}
  {{- end }}
  {{- if $values.dataFrom }}
  dataFrom:
    {{- tpl (toYaml $values.dataFrom) $ | nindent 4 }}
  {{- end }}
{{- end }}

{{/*
This template serves as a blueprint for all external secret objects that are created
within the common library.
*/}}
{{- define "common.class.externalSecret" -}}
  {{- $rootContext := .rootContext -}}
  {{- $obj := .object -}}

  {{- $labels := merge
    ($obj.labels | default dict)
    (include "common.lib.metadata.allLabels" $rootContext | fromYaml)
  -}}
  {{- $annotations := merge
    ($obj.annotations | default dict)
    (include "common.lib.metadata.globalAnnotations" $rootContext | fromYaml)
  -}}
---
apiVersion: external-secrets.io/v1
kind: ExternalSecret
metadata:
  name: {{ printf "%s-%s" $obj.name $obj.identifier }}
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
  {{- if $obj.secretStoreRef }}
  secretStoreRef:
    name: {{ $obj.secretStoreRef.name }}
    kind: {{ $obj.secretStoreRef.kind }}
  {{- end }}
  refreshInterval: {{ $obj.refreshInterval | default "1h"}}
  {{- if $obj.target}}
  target:
    {{- tpl (toYaml $obj.target) $ | nindent 4 }}
  {{- else }}
  target:
    name: {{ printf "%s-%s" $obj.name $obj.identifier }}
  {{- end }}
  {{- if $obj.data }}
  data:
    {{- tpl (toYaml $obj.data) $ | nindent 4 }}
  {{- end }}
  {{- if $obj.dataFrom }}
  dataFrom:
    {{- tpl (toYaml $obj.dataFrom) $ | nindent 4 }}
  {{- end }}
{{- end }}

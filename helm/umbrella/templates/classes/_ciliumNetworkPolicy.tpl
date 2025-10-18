{{/*
This template serves as a blueprint for all Cilium NetworkPolicy objects that are created
within the common library.
*/}}
{{- define "umbrella.class.ciliumNetworkPolicy" -}}
  {{- $values := .Values.ciliumNetworkPolicy -}}
  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.ciliumNetworkPolicy -}}
      {{- $values = . -}}
    {{- end -}}
  {{ end -}}

  {{- $ciliumNetworkPolicyName := include "umbrella.lib.chart.names.fullname" . -}}
  {{- if $values.nameOverride -}}
    {{- $ciliumNetworkPolicyName = printf "%v-%v" $ciliumNetworkPolicyName $values.nameOverride -}}
  {{ end -}}
---
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  {{- with include "umbrella.lib.metadata.allLabels" $ | fromYaml }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with (merge ($values.annotations | default dict) (include "umbrella.lib.metadata.globalAnnotations" $ | fromYaml)) }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
  name: {{ $ciliumNetworkPolicyName }}
spec:
  endpointSelector:
    matchLabels:
      {{- include "umbrella.lib.metadata.selectorLabels" . | nindent 6 }}
  {{- if .Values.ciliumNetworkPolicy.description }}
  description: {{ toYaml $values.description | nindent 4 }}
  {{- end }}
  {{- if $values.ingress }}
  ingress: {{ toYaml $values.ingress | nindent 4 }}
  {{- end }}
  {{- if $values.egress }}
  egress: {{ toYaml $values.egress | nindent 4 }}
  {{- end }}
{{- end }}

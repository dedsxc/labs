{{/*
This template serves as a blueprint for all Secret objects that are created
within the common library.
*/}}
{{- define "umbrella.class.infisicalSecret" -}}
  {{- $fullName := include "umbrella.lib.chart.names.fullname" . -}}
  {{- $infisicalSecretName := $fullName -}}
  {{- $values := .Values.infisicalSecret -}}

  {{- if hasKey . "ObjectValues" -}}
    {{- with .ObjectValues.infisicalSecret -}}
      {{- $values = . -}}
    {{- end -}}
  {{ end -}}

  {{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
    {{- $infisicalSecretName = printf "%v-%v" $infisicalSecretName $values.nameOverride -}}
  {{- end }}
---
apiVersion: secrets.infisical.com/v1alpha1
kind: InfisicalSecret
metadata:
  name: {{ $infisicalSecretName }}
  {{- with (merge ($values.labels | default dict) (include "umbrella.lib.metadata.allLabels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with (merge ($values.annotations | default dict) (include "umbrella.lib.metadata.globalAnnotations" $ | fromYaml)) }}
  annotations: {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  hostAPI: {{ $values.hostAPI | default "https://api.infisical.com" }}
  resyncInterval: {{ $values.resyncInterval | default "10" }}
  {{- if $values.authentication}}
  authentication:
    {{- tpl (toYaml $values.authentication) $ | nindent 4 }}
  {{- else }}
  {{- fail "infisicalSecret.authentication is required" -}}
  {{- end }}
  managedKubeSecretReferences:
    - secretName: {{ $infisicalSecretName }}
      secretNamespace: {{ .Release.Namespace }}
      creationPolicy: {{ $values.creationPolicy | default "Owner"}}
{{- end }}

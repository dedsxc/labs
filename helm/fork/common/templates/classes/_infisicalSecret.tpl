{{/*
This template serves as a blueprint for all Secret objects that are created
within the common library.
*/}}
{{- define "common.class.infisicalSecret" -}}
  {{- $rootContext := .rootContext -}}
  {{- $infisicalSecretObject := .object -}}

  {{- $labels := merge
    ($infisicalSecretObject.labels | default dict)
    (include "common.lib.metadata.allLabels" $rootContext | fromYaml)
  -}}
  {{- $annotations := merge
    ($infisicalSecretObject.annotations | default dict)
    (include "common.lib.metadata.globalAnnotations" $rootContext | fromYaml)
  -}}
---
apiVersion: secrets.infisical.com/v1alpha1
kind: InfisicalSecret
metadata:
  name: {{ printf "%s-%s" $infisicalSecretObject.name $infisicalSecretObject.identifier }}
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
  hostAPI: {{ $infisicalSecretObject.hostAPI | default "https://api.infisical.com" }}
  resyncInterval: {{ $infisicalSecretObject.resyncInterval | default "10" }}
  {{- if $infisicalSecretObject.authentication}}
  authentication:
    {{- tpl (toYaml $infisicalSecretObject.authentication) $ | nindent 4 }}
  {{- else }}
  {{- fail "infisicalSecret.authentication is required" -}}
  {{- end }}
  managedKubeSecretReferences:
    - secretName: {{ $infisicalSecretObject.name }}
      secretNamespace: {{ $rootContext.Release.Namespace }}
      creationPolicy: {{ $infisicalSecretObject.creationPolicy | default "Owner"}}
{{- end }}

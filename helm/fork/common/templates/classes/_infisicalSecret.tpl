{{/*
This template serves as a blueprint for all Secret objects that are created
within the common library.
*/}}
{{- define "common.class.infisicalSecret" -}}
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
apiVersion: secrets.infisical.com/v1alpha1
kind: InfisicalSecret
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
  hostAPI: {{ $obj.hostAPI | default "https://api.infisical.com" }}
  resyncInterval: {{ $obj.resyncInterval | default "10" }}
  {{- if $obj.authentication}}
  authentication:
    {{- tpl (toYaml $obj.authentication) $ | nindent 4 }}
  {{- else }}
  {{- fail "infisicalSecret.authentication is required" -}}
  {{- end }}
  managedKubeSecretReferences:
    - secretName: {{ $obj.name }}
      secretNamespace: {{ $rootContext.Release.Namespace }}
      creationPolicy: {{ $obj.creationPolicy | default "Owner"}}
{{- end }}

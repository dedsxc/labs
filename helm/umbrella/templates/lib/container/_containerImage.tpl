{{/*
Image used by the main container.
*/}}
{{- define "umbrella.lib.container.image" -}}
  {{- $imageRepo := .Values.image.repository -}}
  {{- $imageTag := coalesce .Values.image.overrideTag .Values.image.tag .Chart.AppVersion "0.0.1" -}}

  {{- if kindIs "float64" $imageTag -}}
    {{- $imageTag = .Values.image.tag | toString -}}
  {{- end -}}

  {{- if and $imageRepo $imageTag -}}
    {{- printf "%s:%s" $imageRepo $imageTag -}}
  {{- end -}}
{{- end -}}

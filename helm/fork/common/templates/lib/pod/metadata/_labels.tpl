{{- /*
Returns the value for labels
*/ -}}
{{- define "common.lib.pod.metadata.labels" -}}
  {{- $rootContext := .rootContext -}}
  {{- $controllerObject := .controllerObject -}}

  {{- /* Default labels */ -}}
  {{- $labels := merge
    (dict "app.kubernetes.io/controller" $controllerObject.identifier)
  -}}

  {{- /* Include global labels if specified */ -}}
  {{- if $rootContext.Values.global.propagateGlobalMetadataToPods -}}
    {{- $labels = merge
      (include "common.lib.metadata.globalLabels" $rootContext | fromYaml)
      $labels
    -}}
  {{- end -}}

  {{- /* Fetch the Pod selectorLabels */ -}}
  {{- $selectorLabels := include "common.lib.metadata.selectorLabels" $rootContext | fromYaml -}}
  {{- if not (empty $selectorLabels) -}}
    {{- $labels = merge
      $selectorLabels
      $labels
    -}}
  {{- end -}}

  {{- /* Fetch the configured labels */ -}}
  {{- $ctx := dict "rootContext" $rootContext "controllerObject" $controllerObject -}}
  {{- $podlabels := (include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "labels")) | fromYaml -}}
  {{- if not (empty $podlabels) -}}
    {{- $labels = merge
      $podlabels
      $labels
    -}}
  {{- end -}}

  {{- if not (empty $labels) -}}
    {{- $labels | toYaml -}}
  {{- end -}}
{{- end -}}

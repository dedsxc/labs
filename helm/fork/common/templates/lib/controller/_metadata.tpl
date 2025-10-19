{{- define "common.lib.controller.metadata.labels" -}}
  {{- $root := $ -}}
  {{- $controller := (get $root.Values "controller" | default dict) -}}
  {{-
    $labels := (
      merge
        ($controller.labels | default dict)
        (include "common.lib.metadata.allLabels" $root | fromYaml)
    )
  -}}
  {{- with $labels -}}
    {{- toYaml . -}}
  {{- end -}}
{{- end -}}

{{- define "common.lib.controller.metadata.annotations" -}}
  {{- $root := $ -}}
  {{- $controller := (get $root.Values "controller" | default dict) -}}
  {{-
    $annotations := (
      merge
        ($controller.annotations | default dict)
        (include "common.lib.metadata.globalAnnotations" $root | fromYaml)
    )
  -}}
  {{- with $annotations -}}
    {{- toYaml . -}}
  {{- end -}}
{{- end -}}

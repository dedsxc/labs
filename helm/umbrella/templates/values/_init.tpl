# Merge the local chart values and the common chart defaults

{{- define "umbrella.values.init" -}}
  {{- if .Values.umbrella -}}
    {{- $defaultValues := deepCopy .Values.umbrella -}}
    {{- $userValues := deepCopy (omit .Values "umbrella") -}}
    {{- range $name, $bundle := $defaultValues.valueBundles -}}
    {{- if or $bundle.enabled (and $userValues.valueBundles (get $userValues.valueBundles $name) ((get $userValues.valueBundles $name).enabled)) -}}
    {{- $defaultValues := mustMergeOverwrite $defaultValues $bundle.values -}}
    {{- end -}}
    {{- end -}}
    {{- $_ := set $defaultValues "additionalContainers" dict -}}
    {{- $mergedValues := mustMergeOverwrite $defaultValues $userValues -}}
    {{- $_ := set . "Values" (deepCopy $mergedValues) -}}
  {{- end -}}
{{- end -}}

{{/*
This template serves as a blueprint for all PersistentVolumeClaim objects that are created
within the common library.
*/}}
{{- define "umbrella.class.pv" -}}
{{- $values := .Values.persistence -}}
{{- if hasKey . "ObjectValues" -}}
  {{- with .ObjectValues.persistence -}}
    {{- $values = . -}}
  {{- end -}}
{{ end -}}
{{- $pvcName := include "umbrella.lib.chart.names.fullname" . -}}
{{- if and (hasKey $values "nameOverride") $values.nameOverride -}}
  {{- if not (eq $values.nameOverride "-") -}}
    {{- $pvcName = printf "%v-%v" $pvcName $values.nameOverride -}}
  {{ end -}}
{{ end }}
---
kind: PersistentVolume
apiVersion: v1
metadata:
  name: {{ $pvcName }}
  {{- with (merge ($values.labels | default dict) (include "umbrella.lib.metadata.allLabels" $ | fromYaml)) }}
  labels: {{- toYaml . | nindent 4 }}
  {{- end }}
  annotations:
    {{- if $values.retain }}
    "helm.sh/resource-policy": keep
    {{- end }}
    {{- with (merge ($values.annotations | default dict) (include "umbrella.lib.metadata.globalAnnotations" $ | fromYaml)) }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  accessModes:
    - {{ required (printf "accessMode is required for PV %v" $pvcName) $values.accessMode | quote }}
  capacity:
    storage: {{ required (printf "size is required for PV %v" $pvcName) $values.size | quote }}
  {{- if $values.claimRefName }}
  claimRef:
    name: {{ $values.claimRefName | quote }}
    namespace: {{ default $.Release.Namespace .namespace }}
  {{- end }}
  {{- if $values.volume.hostPath }}
  hostPath:
  {{- if $values.volume.hostPath }}
    path: {{ $values.volume.hostPath | quote }}
  {{- end }}
    type: {{ $values.volume.type | quote }}
  {{- end }}
  {{- if $values.storageClass }}
  storageClassName: {{ if (eq "-" $values.storageClass) }}""{{- else }}{{ $values.storageClass | quote }}{{- end }}
  {{- end }}
{{- end -}}

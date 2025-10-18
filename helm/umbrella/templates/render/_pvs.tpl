{{/*
Renders the Persistent Volume objects required by the chart.
*/}}
{{- define "umbrella.render.pvs" -}}
  {{- /* Generate pvc as required */ -}}
  {{- range $index, $PVC := .Values.persistence -}}
    {{- if and $PVC.enabled (eq (default "pvc" $PVC.type) "pvc") (not $PVC.existingClaim) -}}
      {{- $persistenceValues := $PVC -}}
      {{- if not $persistenceValues.nameOverride -}}
        {{- $_ := set $persistenceValues "nameOverride" $index -}}
      {{- end -}}
      {{- $_ := set $ "ObjectValues" (dict "persistence" $persistenceValues) -}}
      {{- if (and $PVC.volume (default false $PVC.volume.enabled)) -}}
        {{- include "umbrella.class.pv" $ | nindent 0 -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

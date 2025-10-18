{{/*
Renders the serviceAccount object required by the chart.
*/}}
{{- define "umbrella.render.serviceAccount" -}}
  {{- if .Values.serviceAccount.create -}}

    {{- /* Create a service account secret */ -}}
    {{- $serviceAccountName := include "umbrella.lib.chart.names.serviceAccountName" . -}}
    {{- $_ := set .Values.secrets "sa-token" (dict "enabled" true "annotations" (dict "kubernetes.io/service-account.name" $serviceAccountName) "type" "kubernetes.io/service-account-token") -}}

    {{- include "umbrella.class.serviceAccount" $ | nindent 0 -}}
  {{- end -}}
{{- end -}}

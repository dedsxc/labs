{{- /*
Returns the value for dnsPolicy
*/ -}}
{{- define "common.lib.pod.field.dnsPolicy" -}}
  {{- $ctx := .ctx -}}
  {{- $controllerObject := $ctx.controllerObject -}}

  {{- /* Default to "ClusterFirst" */ -}}
  {{- $dnsPolicy := "ClusterFirst" -}}

  {{- /* Get hostNetwork value "" */ -}}
  {{- $hostNetwork:= $ctx.hostNetwork -}}
  {{- if (eq $hostNetwork "true") -}}
    {{- $dnsPolicy = "ClusterFirstWithHostNet" -}}
  {{- end -}}

  {{- $dnsPolicy -}}
{{- end -}}

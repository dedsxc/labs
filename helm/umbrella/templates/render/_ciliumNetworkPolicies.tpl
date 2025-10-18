{{/*
Renders the Cilium NetworkPolicy objects required by the chart.
*/}}
{{- define "umbrella.render.ciliumNetworkPolicies" -}}
  {{- /* Generate named Cilium NetworkPolicy as required */ -}}
  {{- range $name, $ciliumNetworkPolicy := .Values.ciliumNetworkPolicy -}}
    {{- $ciliumNetworkPolicyEnabled := true -}}
    {{- if hasKey $ciliumNetworkPolicy "enabled" -}}
      {{- $ciliumNetworkPolicyEnabled = $ciliumNetworkPolicy.enabled -}}
    {{- end -}}
    {{- if $ciliumNetworkPolicyEnabled -}}
      {{/* set the default nameOverride to the ciliumNetworkPolicy name */}}
      {{- if not $ciliumNetworkPolicy.nameOverride -}}
        {{- $_ := set $ciliumNetworkPolicy "nameOverride" $name -}}
      {{ end -}}

      {{/* Include the Cilium Network Policy class */}}
      {{- $_ := set $ "ObjectValues" (dict "ciliumNetworkPolicy" $ciliumNetworkPolicy) -}}
      {{- include "umbrella.class.ciliumNetworkPolicy" $ | nindent 0 -}}
      {{- $_ := unset $.ObjectValues "ciliumNetworkPolicy" -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

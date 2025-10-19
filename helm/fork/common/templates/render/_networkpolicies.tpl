{{/*
Renders the networkPolicy objects required by the chart.
*/}}
{{- define "common.render.networkpolicies" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate networkPolicy as required */ -}}
  {{- $enabledNetworkPolicies := (include "common.lib.networkpolicy.enabledNetworkPolicies" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledNetworkPolicies -}}
    {{- /* Generate object from the raw persistence values */ -}}
    {{- $networkPolicyObject := (include "common.lib.networkpolicy.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Perform validations on the networkPolicy before rendering */ -}}
    {{- include "common.lib.networkpolicy.validate" (dict "rootContext" $ "object" $networkPolicyObject) -}}

    {{- /* Include the networkPolicy class */ -}}
    {{- include "common.class.networkpolicy" (dict "rootContext" $ "object" $networkPolicyObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}

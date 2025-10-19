{{/*
Return a ServiceAccount Object by its Identifier.
*/}}
{{- define "common.lib.serviceAccount.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledServiceAccounts := (include "common.lib.serviceAccount.enabledServiceAccounts" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledServiceAccounts $identifier) -}}
    {{- get $enabledServiceAccounts $identifier | toYaml -}}
  {{- end -}}
{{- end -}}

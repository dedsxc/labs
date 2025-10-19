{{/*
Return a RoleBinding Object by its Identifier.
*/}}
{{- define "common.lib.rbac.roleBinding.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledRoleBindings := (include "common.lib.rbac.roleBinding.enabledRoleBindings" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledRoleBindings $identifier) -}}
    {{- $objectValues := get $enabledRoleBindings $identifier -}}
    {{- include "common.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledRoleBindings)) -}}
  {{- end -}}
{{- end -}}

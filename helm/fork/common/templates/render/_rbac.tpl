{{/*
Renders RBAC objects required by the chart.
*/}}
{{- define "common.render.rbac" -}}
  {{- $rootContext := . -}}
  {{- include "common.render.rbac.roles" (dict "rootContext" $rootContext) -}}
  {{- include "common.render.rbac.roleBindings" (dict "rootContext" $rootContext) -}}
{{ end }}

{{/*
Renders RBAC Role objects required by the chart.
*/}}
{{- define "common.render.rbac.roles" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledRoles := (include "common.lib.rbac.role.enabledRoles" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledRoles -}}
    {{- /* Generate object from the raw role values */ -}}
    {{- $roleObject := (include "common.lib.rbac.role.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Perform validations on the role before rendering */ -}}
    {{- include "common.lib.rbac.role.validate" (dict "rootContext" $rootContext "object" $roleObject) -}}

    {{/* Include the role class */}}
    {{- include "common.class.rbac.Role" (dict "rootContext" $rootContext "object" $roleObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}

{{/*
Renders RBAC RoleBinding objects required by the chart.
*/}}
{{- define "common.render.rbac.roleBindings" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledRoleBindings := (include "common.lib.rbac.roleBinding.enabledRoleBindings" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledRoleBindings -}}
    {{- /* Generate object from the raw role values */ -}}
    {{- $roleBindingObject := (include "common.lib.rbac.roleBinding.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{/* Include the RoleBinding class */}}
    {{- include "common.class.rbac.roleBinding" (dict "rootContext" $rootContext "object" $roleBindingObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}

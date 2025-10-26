{{/*
Renders the controller objects required by the chart.
*/}}
{{- define "common.render.controllers" -}}
  {{- $rootContext := $ -}}
  {{- $identifier := "main"}}

  {{- /* Create object from the raw controller values */ -}}
  {{- $controllerObject := (include "common.lib.controller.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

  {{- /* Perform validations on the controller before rendering */ -}}
  {{- include "common.lib.controller.validate" (dict "rootContext" $rootContext "object" $controllerObject) -}}

  {{- if eq $controllerObject.type "deployment" -}}
    {{- $deploymentObject := (include "common.lib.deployment.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $controllerObject )) | fromYaml -}}
    {{- include "common.lib.deployment.validate" (dict "rootContext" $rootContext "object" $deploymentObject) -}}
    {{- include "common.class.deployment" (dict "rootContext" $rootContext "object" $deploymentObject) | nindent 0 -}}

  {{- else if eq $controllerObject.type "cronjob" -}}
    {{- $cronjobObject := (include "common.lib.cronjob.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $controllerObject )) | fromYaml -}}
    {{- include "common.lib.cronjob.validate" (dict "rootContext" $rootContext "object" $cronjobObject) -}}
    {{- include "common.class.cronjob" (dict "rootContext" $rootContext "object" $cronjobObject) | nindent 0 -}}

  {{- else if eq $controllerObject.type "daemonset" -}}
    {{- $daemonsetObject := (include "common.lib.daemonset.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $controllerObject )) | fromYaml -}}
    {{- include "common.lib.daemonset.validate" (dict "rootContext" $rootContext "object" $daemonsetObject) -}}
    {{- include "common.class.daemonset" (dict "rootContext" $rootContext "object" $daemonsetObject) | nindent 0 -}}

  {{- else if eq $controllerObject.type "statefulset"  -}}
    {{- $statefulsetObject := (include "common.lib.statefulset.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $controllerObject )) | fromYaml -}}
    {{- include "common.lib.statefulset.validate" (dict "rootContext" $rootContext "object" $statefulsetObject) -}}
    {{- include "common.class.statefulset" (dict "rootContext" $rootContext "object" $statefulsetObject) | nindent 0 -}}

  {{- else if eq $controllerObject.type "job"  -}}
    {{- $jobObject := (include "common.lib.job.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $controllerObject )) | fromYaml -}}
    {{- include "common.lib.job.validate" (dict "rootContext" $rootContext "object" $jobObject) -}}
    {{- include "common.class.job" (dict "rootContext" $rootContext "object" $jobObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}

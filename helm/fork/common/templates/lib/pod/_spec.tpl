{{- /*
The pod definition included in the controller.
*/ -}}
{{- define "common.lib.pod.spec" -}}
  {{- $rootContext := .rootContext -}}
  {{- $controllerObject := .controllerObject -}}
  {{- $ctx := dict "rootContext" $rootContext "controllerObject" $controllerObject -}}

enableServiceLinks: {{ include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "enableServiceLinks" "default" false) }}
serviceAccountName: {{ include "common.lib.pod.field.serviceAccountName" (dict "ctx" $ctx) | trim }}
automountServiceAccountToken: {{ include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "automountServiceAccountToken" "default" true) }}
  {{- with (include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "priorityClassName")) }}
priorityClassName: {{ . | trim }}
  {{- end -}}
  {{- with (include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "runtimeClassName")) }}
runtimeClassName: {{ . | trim }}
  {{- end -}}
  {{- with (include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "schedulerName")) }}
schedulerName: {{ . | trim }}
  {{- end -}}
  {{- with (include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "securityContext")) }}
securityContext: {{ . | nindent 2 }}
  {{- end -}}
  {{- with (include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "hostname")) }}
hostname: {{ . | trim }}
  {{- end }}
hostIPC: {{ include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "hostIPC" "default" false) }}
hostNetwork: {{ include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "hostNetwork" "default" false) }}
hostPID: {{ include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "hostPID" "default" false) }}
  {{- if ge ($rootContext.Capabilities.KubeVersion.Minor | int) 29 }}
    {{- with (include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "hostUsers")) }}
hostUsers: {{ . | trim }}
    {{- end -}}
    {{- with (include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "shareProcessNamespace")) }}
shareProcessNamespace: {{ . | trim }}
    {{- end -}}
  {{- end }}
dnsPolicy: {{ include "common.lib.pod.field.dnsPolicy" (dict "ctx" $ctx) | trim }}
  {{- with (include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "dnsConfig")) }}
dnsConfig: {{ . | nindent 2 }}
  {{- end -}}
  {{- with (include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "hostAliases")) }}
hostAliases: {{ . | nindent 2 }}
  {{- end -}}
  {{- with (include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "imagePullSecrets")) }}
imagePullSecrets: {{ . | nindent 2 }}
  {{- end -}}
  {{- with (include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "terminationGracePeriodSeconds")) }}
terminationGracePeriodSeconds: {{ . | trim }}
  {{- end -}}
  {{- if ge ($rootContext.Capabilities.KubeVersion.Minor | int) 32 }}
    {{- with (include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "resources")) }}
resources: {{ . | nindent 2 }}
    {{- end -}}
    {{- with (include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "resourceClaims")) }}
resourceClaims: {{ . | nindent 2 }}
    {{- end -}}
  {{- end -}}
  {{- with (include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "restartPolicy")) }}
restartPolicy: {{ . | trim }}
  {{- end -}}
  {{- with (include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "nodeSelector")) }}
nodeSelector: {{ . | nindent 2 }}
  {{- end -}}
  {{- with (include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "affinity")) }}
affinity: {{- tpl . $rootContext | nindent 2 }}
  {{- end -}}
  {{- with (include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "topologySpreadConstraints")) }}
topologySpreadConstraints: {{- tpl . $rootContext | nindent 2 }}
  {{- end -}}
  {{- with (include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "tolerations")) }}
tolerations: {{ . | nindent 2 }}
  {{- end }}
  {{- with (include "common.lib.pod.getOption" (dict "ctx" $ctx "option" "schedulingGates")) }}
schedulingGates: {{ . | nindent 2 }}
  {{- end }}
  {{- with (include "common.lib.pod.field.initContainers" (dict "ctx" $ctx) | trim) }}
initContainers: {{ . | nindent 2 }}
  {{- end -}}
  {{- with (include "common.lib.pod.field.containers" (dict "ctx" $ctx) | trim) }}
containers: {{ . | nindent 2 }}
  {{- end -}}
  {{- with (include "common.lib.pod.field.volumes" (dict "ctx" $ctx) | trim) }}
volumes: {{ . | nindent 2 }}
  {{- end -}}
{{- end -}}

{{- define "common.lib.pod.spec" -}}
  {{- $rootContext := .rootContext -}}
  {{- $controllerObject := .controllerObject -}}
  {{- $ctx := dict "rootContext" $rootContext "controllerObject" $controllerObject -}}

enableServiceLinks: {{ $rootContext.Values.enableServiceLinks }}
serviceAccountName: {{ include "common.lib.pod.field.serviceAccountName" (dict "ctx" $ctx) | trim }}
automountServiceAccountToken: {{ $rootContext.Values.automountServiceAccountToken }}
  {{- with $rootContext.Values.priorityClassName }}
priorityClassName: {{ . | trim }}
  {{- end -}}
  {{- with $rootContext.Values.runtimeClassName }}
runtimeClassName: {{ . | trim }}
  {{- end -}}
  {{- with $rootContext.Values.schedulerName }}
schedulerName: {{ . | trim }}
  {{- end -}}
  {{- with $rootContext.Values.securityContext }}
securityContext: {{ toYaml . | nindent 2 }}
  {{- end -}}
  {{- with $rootContext.Values.hostname }}
hostname: {{ . | trim }}
  {{- end -}}
hostNetwork: {{ $rootContext.Values.hostNetwork | default "false" }}
dnsPolicy: {{ include "common.lib.pod.field.dnsPolicy" (dict "ctx" $ctx) | trim }}
  {{- with $rootContext.Values.dnsConfig }}
dnsConfig: {{ toYaml . | nindent 2 }}
  {{- end -}}
  {{- with $rootContext.Values.hostAliases }}
hostAliases: {{ toYaml . | nindent 2 }}
  {{- end -}}
  {{- with $rootContext.Values.imagePullSecrets }}
imagePullSecrets: {{ toYaml . | nindent 2 }}
  {{- end -}}
  {{- with $rootContext.Values.terminationGracePeriodSeconds }}
terminationGracePeriodSeconds: {{ . | trim }}
  {{- end -}}
  {{- if ge ($rootContext.Capabilities.KubeVersion.Minor | int) 32 }}
    {{- with $rootContext.Values.resources }}
resources: {{ toYaml . | nindent 2 }}
    {{- end -}}
    {{- with $rootContext.Values.resourceClaims }}
resourceClaims: {{ toYaml . | nindent 2 }}
    {{- end -}}
  {{- end -}}
  {{- with $rootContext.Values.restartPolicy }}
restartPolicy: {{ . | trim }}
  {{- end -}}
  {{- with $rootContext.Values.nodeSelector }}
nodeSelector: {{ toYaml . | nindent 2 }}
  {{- end -}}
  {{- with $rootContext.Values.affinity }}
affinity: {{ tpl (toYaml .) $rootContext | nindent 2 }}
  {{- end -}}
  {{- with $rootContext.Values.topologySpreadConstraints }}
topologySpreadConstraints: {{ toYaml . | nindent 2 }}
  {{- end -}}
  {{- with $rootContext.Values.tolerations }}
tolerations: {{ toYaml . | nindent 2 }}
  {{- end -}}
  {{- with $rootContext.Values.schedulingGates }}
schedulingGates: {{ toYaml . | nindent 2 }}
  {{- end -}}
  {{- with (include "common.lib.pod.field.initContainers" (dict "ctx" $ctx) | fromYaml) }}
initContainers: {{ toYaml . | nindent 2 }}
  {{- end -}}
  {{- with (include "common.lib.pod.field.containers" (dict "ctx" $ctx) | fromYaml) }}
containers: {{ toYaml . | nindent 2 }}
  {{- end -}}
  {{- with (include "common.lib.pod.field.volumes" (dict "ctx" $ctx) | fromYaml) }}
volumes: {{ toYaml . | nindent 2 }}
  {{- end -}}
{{- end -}}

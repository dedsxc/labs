{{- /* The main container included in the controller */ -}}
{{- define "umbrella.lib.controller.mainContainer" -}}
- name: {{ include "umbrella.lib.chart.names.fullname" . }}
  image: {{ include "umbrella.lib.container.image" . }}
  imagePullPolicy: {{ .Values.image.pullPolicy | default "IfNotPresent" }}
  {{- with .Values.command }}
  command:
    {{- if kindIs "string" . }}
    - {{ . | quote }}
    {{- else }}
      {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with .Values.args }}
  args:
    {{- if kindIs "string" . }}
    - {{ . | quote }}
    {{- else }}
    {{ toYaml . | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with .Values.securityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.lifecycle }}
  lifecycle:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.termination.messagePath }}
  terminationMessagePath: {{ . }}
  {{- end }}
  {{- with .Values.termination.messagePolicy }}
  terminationMessagePolicy: {{ . }}
  {{- end }}
  env:
  {{- with .Values.env }}
    {{- get (fromYaml (include "umbrella.lib.container.envVars" $)) "env" | toYaml | nindent 4 -}}
  {{- end }}
  {{- with .Values.envFrom }}
  envFrom:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with (include "umbrella.lib.container.ports" . | trim) }}
  ports:
    {{- nindent 4 . }}
  {{- end }}
  {{- with (include "umbrella.lib.container.volumeMounts" . | trim) }}
  volumeMounts:
    {{- nindent 4 . }}
  {{- end }}
  {{- include "umbrella.lib.container.probes" . | trim | nindent 2 }}
  {{- with .Values.resources }}
  resources:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}

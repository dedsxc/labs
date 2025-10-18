{{/* Expand the name of the chart */}}
{{- define "umbrella.lib.chart.names.name" -}}
  {{- $globalNameOverride := "" -}}
  {{- if hasKey .Values "global" -}}
    {{- $globalNameOverride = (default $globalNameOverride .Values.global.nameOverride) -}}
  {{- end -}}
  {{- default .Chart.Name (default .Values.nameOverride $globalNameOverride) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "umbrella.lib.chart.names.fullname" -}}
  {{- $name := include "umbrella.lib.chart.names.name" . -}}
  {{- $globalFullNameOverride := "" -}}
  {{- if hasKey .Values "global" -}}
    {{- $globalFullNameOverride = (default $globalFullNameOverride .Values.global.fullnameOverride) -}}
  {{- end -}}
  {{- if or .Values.fullnameOverride $globalFullNameOverride -}}
    {{- $name = default .Values.fullnameOverride $globalFullNameOverride -}}
  {{- else -}}
    {{- if contains $name .Release.Name -}}
      {{- $name = .Release.Name -}}
    {{- else -}}
      {{- $name = printf "%s-%s" .Release.Name $name -}}
    {{- end -}}
  {{- end -}}
  {{- trunc 63 $name | trimSuffix "-" -}}
{{- end -}}

{{/* Create chart name and version as used by the chart label */}}
{{- define "umbrella.lib.chart.names.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Create the name of the ServiceAccount to use */}}
{{- define "umbrella.lib.chart.names.serviceAccountName" -}}
  {{- if .Values.serviceAccount.create -}}
    {{- default (include "umbrella.lib.chart.names.fullname" .) .Values.serviceAccount.name -}}
  {{- else -}}
    {{- default "default" .Values.serviceAccount.name -}}
  {{- end -}}
{{- end -}}

{{/* Create the name of the HorizontalPodAutoscaler to use */}}
{{- define "umbrella.lib.chart.names.horizontalPodAutoscalerName" -}}
  {{- if .Values.horizontalPodAutoscaler.create -}}
    {{- default (include "umbrella.lib.chart.names.fullname" .) .Values.horizontalPodAutoscaler.name -}}
  {{- else -}}
    {{- default "default" .Values.horizontalPodAutoscaler.name -}}
  {{- end -}}
{{- end -}}

{{/* Create the name of the Buoyant DataPlane to use */}}
{{- define "umbrella.lib.chart.names.buoyantDataPlane" -}}
  {{- if .Values.linkerd.buoyantDataPlane.enabled -}}
    {{- default (include "umbrella.lib.chart.names.fullname" .) .Values.linkerd.buoyantDataPlane.name -}}
  {{- else -}}
    {{- default "default" .Values.linkerd.buoyantDataPlane.name -}}
  {{- end -}}
{{- end -}}

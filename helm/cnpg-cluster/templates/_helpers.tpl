{{/*
Cluster name: cluster.clusterName, default <release>-cluster.
*/}}
{{- define "cnpg-cluster.name" -}}
{{- .Values.cluster.clusterName | default (printf "%s-cluster" .Release.Name) -}}
{{- end }}

{{/*
global.cnpg.<key> (umbrella charts set it once for every cnpg-cluster subchart), or "".
*/}}
{{- define "cnpg-cluster.global" -}}
{{- dig "cnpg" .key "" (.ctx.Values.global | default dict) -}}
{{- end }}

{{/*
Effective off-cluster backup settings, as YAML: the `backup` values of this chart, with every empty
key filled from global.backup (values set here win). Adds `on` (bool) and the resolved names.
*/}}
{{- define "cnpg-cluster.backup" -}}
{{- $b := merge (deepCopy (.Values.backup | default dict)) (deepCopy ((.Values.global | default dict).backup | default dict)) -}}
{{- $s3 := $b.s3 | default dict -}}
{{- $name := include "cnpg-cluster.name" . -}}
{{- $_ := set $b "on" (and (ne (toString .Values.backup.enabled) "false") (ne ($s3.destinationPath | default "") "")) -}}
{{- $_ := set $b "objectStore" (printf "%s-backup" $name) -}}
{{- $_ := set $b "secretName" ($s3.secretName | default (printf "%s-backup-s3" $name)) -}}
{{- $_ := set $b "restoreFrom" (dig "restore" "from" "" $b) -}}
{{- toYaml $b -}}
{{- end }}

{{/*
ObjectStore spec.configuration for a destination path (dict "ctx" $ "b" <backup> "path" <s3 path>).
The cluster writes to <path>/<namespace>/<clusterName>/ (serverName = cluster name).
*/}}
{{- define "cnpg-cluster.objectStoreConfiguration" -}}
{{- $s3 := .b.s3 -}}
destinationPath: {{ printf "%s/%s" (trimSuffix "/" .path) .ctx.Release.Namespace | quote }}
{{- with $s3.endpointURL }}
endpointURL: {{ . | quote }}
{{- end }}
s3Credentials:
  accessKeyId:
    name: {{ .b.secretName }}
    key: ACCESS_KEY_ID
  secretAccessKey:
    name: {{ .b.secretName }}
    key: ACCESS_SECRET_KEY
  {{- if $s3.region }}
  region:
    name: {{ .b.secretName }}
    key: ACCESS_REGION
  {{- end }}
wal:
  compression: gzip
data:
  compression: gzip
{{- end }}

{{/*
Annotations with the Argo CD sync options merged in
(dict "ctx" $ "annotations" <map> "skipDryRun" <bool> "deleteOnly" <bool>):
- cluster.keepOnDelete: Prune=false,Delete=false on the Cluster, so Argo CD never deletes the database, whether
  it leaves Git or its Application is deleted. deleteOnly (the backup resources): Delete=false only, so they stay
  with a Cluster kept after its Application is deleted (it keeps archiving), but go when backups are switched off;
- skipDryRun: SkipDryRunOnMissingResource=true, for CRDs installed by another Argo CD app.
Options already set by the user (argocd.argoproj.io/sync-options) are kept.
*/}}
{{- define "cnpg-cluster.annotations" -}}
{{- $ann := deepCopy (.annotations | default dict) -}}
{{- $key := "argocd.argoproj.io/sync-options" -}}
{{- $opts := list -}}
{{- with (get $ann $key) }}{{ $opts = splitList "," . }}{{ end -}}
{{- if .skipDryRun }}{{ $opts = append $opts "SkipDryRunOnMissingResource=true" }}{{ end -}}
{{- if .ctx.Values.cluster.keepOnDelete }}
{{- if not .deleteOnly }}{{ $opts = append $opts "Prune=false" }}{{ end }}
{{- $opts = append $opts "Delete=false" }}
{{- end -}}
{{- $clean := list -}}
{{- range $opts }}{{ $o := trim . }}{{ if and $o (not (has $o $clean)) }}{{ $clean = append $clean $o }}{{ end }}{{ end -}}
{{- if $clean }}{{ $_ := set $ann $key (join "," $clean) }}{{ end -}}
{{- if $ann }}{{ toYaml $ann }}{{ end -}}
{{- end }}

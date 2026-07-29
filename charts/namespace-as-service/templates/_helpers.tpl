{{/*
Expand the name of the chart.
*/}}
{{- define "namespace-as-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "namespace-as-service.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "namespace-as-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "namespace-as-service.labels" -}}
helm.sh/chart: {{ include "namespace-as-service.chart" . }}
{{ include "namespace-as-service.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end }}

{{- define "namespace-as-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "namespace-as-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Validate tenant and namespaces.

Single-tenant chart: every workload namespace MUST be prefixed with "<tenant>-"
(e.g. tenant=test → test-dev, test-uat). Devops is always "<tenant>-devops".
Mixing another product/tenant prefix in the same release is rejected.
*/}}
{{- define "namespace-as-service.validate" -}}
{{- if not .Values.tenant }}
{{- fail "tenant is required" }}
{{- end }}
{{- if contains "/" .Values.tenant }}
{{- fail "tenant must not contain '/'" }}
{{- end }}
{{- if not .Values.namespaces }}
{{- fail "namespaces must be a non-empty list of objects with name" }}
{{- end }}
{{- $tenant := .Values.tenant -}}
{{- $prefix := printf "%s-" $tenant -}}
{{- $devops := printf "%s-devops" $tenant -}}
{{- $seen := dict -}}
{{- range $i, $ns := .Values.namespaces }}
{{- if not $ns.name }}
{{- fail (printf "namespaces[%d].name is required" $i) }}
{{- end }}
{{- if not (hasPrefix $prefix $ns.name) }}
{{- fail (printf "namespaces[%d].name %q must start with %q (single tenant per release; devops is %q)" $i $ns.name $prefix $devops) }}
{{- end }}
{{- $suffix := trimPrefix $prefix $ns.name -}}
{{- if eq $suffix "" }}
{{- fail (printf "namespaces[%d].name %q must include an env suffix after %q (e.g. %sdev)" $i $ns.name $prefix $prefix) }}
{{- end }}
{{- if eq $ns.name $devops }}
{{- fail (printf "namespaces[%d].name %q is reserved; devops namespace is created automatically when argocd/tekton is enabled" $i $ns.name) }}
{{- end }}
{{- if hasKey $seen $ns.name }}
{{- fail (printf "duplicate namespaces[].name %q" $ns.name) }}
{{- end }}
{{- $_ := set $seen $ns.name true -}}
{{- end }}
{{- end }}

{{- define "namespace-as-service.devopsEnabled" -}}
{{- or .Values.argocd.enabled .Values.tekton.enabled -}}
{{- end }}

{{- define "namespace-as-service.devopsNamespace" -}}
{{- printf "%s-devops" .Values.tenant -}}
{{- end }}

{{- define "namespace-as-service.workloadNames" -}}
{{- $names := list -}}
{{- range .Values.namespaces }}
{{- $names = append $names .name -}}
{{- end -}}
{{- join "," $names -}}
{{- end }}

{{/*
Resolve instanceSize for a namespace config dict $cfg (may be empty).
Usage: include "namespace-as-service.resolveInstanceSize" (dict "root" . "cfg" $cfg)
*/}}
{{- define "namespace-as-service.resolveInstanceSize" -}}
{{- $root := .root -}}
{{- $cfg := .cfg | default dict -}}
{{- $size := $cfg.instanceSize | default $root.Values.instanceSize | default "kgen.medium" -}}
{{- if eq $size "" }}{{- $size = "kgen.medium" -}}{{- end -}}
{{- $size -}}
{{- end }}

{{/*
Quota hard map for a namespace config.

Paths:
  1) Default: omit resourceQuota.hard → full preset from instanceSize (templates/_sizes.tpl)
  2) Merge: named instanceSize + partial resourceQuota.hard/custom → preset then overlay
  3) Replace (no default): instanceSize: custom  OR  resourceQuota.replace: true
     → only resourceQuota.hard (+ custom keys); preset is NOT applied
*/}}
{{- define "namespace-as-service.quotaHard" -}}
{{- $root := .root -}}
{{- $cfg := .cfg | default dict -}}
{{- $size := include "namespace-as-service.resolveInstanceSize" (dict "root" $root "cfg" $cfg) -}}
{{- $rq := $cfg.resourceQuota | default dict -}}
{{- $hard := $rq.hard | default dict -}}
{{- $custom := $rq.custom | default dict -}}
{{- $replace := or (eq $size "custom") (eq ($rq.replace | default false) true) -}}
{{- $base := dict -}}
{{- $sizes := include "namespace-as-service.sizes" $root | fromYaml -}}
{{- if $replace -}}
  {{- if not $hard -}}
    {{- fail "resourceQuota.replace / instanceSize custom requires resourceQuota.hard (no default preset is applied)" -}}
  {{- end -}}
  {{- $base = dict -}}
{{- else -}}
  {{- $preset := index $sizes $size -}}
  {{- if not $preset -}}
    {{- fail (printf "unknown instanceSize %q (set e.g. kgen.medium; presets live in templates/_sizes.tpl)" $size) -}}
  {{- end -}}
  {{- $base = $preset.resourceQuota.hard | default dict | toYaml | fromYaml -}}
{{- end -}}
{{- $merged := mergeOverwrite $base $hard $custom -}}
{{- toYaml $merged -}}
{{- end }}

{{/*
LimitRange limits list for a namespace config.

Replace (no default): instanceSize: custom OR limitRange.replace: true → only limits (+ customLimits).
Otherwise: preset from instanceSize, or full limits list if provided.
*/}}
{{- define "namespace-as-service.limitRangeLimits" -}}
{{- $root := .root -}}
{{- $cfg := .cfg | default dict -}}
{{- $size := include "namespace-as-service.resolveInstanceSize" (dict "root" $root "cfg" $cfg) -}}
{{- $lr := $cfg.limitRange | default dict -}}
{{- $limits := $lr.limits | default list -}}
{{- $custom := $lr.customLimits | default list -}}
{{- $replace := or (eq $size "custom") (eq ($lr.replace | default false) true) -}}
{{- $sizes := include "namespace-as-service.sizes" $root | fromYaml -}}
{{- $base := list -}}
{{- if $replace -}}
  {{- if and $root.Values.limitRange.enabled (not $limits) -}}
    {{- fail "limitRange.replace / instanceSize custom with limitRange.enabled requires limitRange.limits (no default preset)" -}}
  {{- end -}}
  {{- $base = $limits -}}
{{- else -}}
  {{- $preset := index $sizes $size -}}
  {{- if not $preset -}}
    {{- fail (printf "unknown instanceSize %q (set e.g. kgen.medium; presets live in templates/_sizes.tpl)" $size) -}}
  {{- end -}}
  {{- if $limits -}}
    {{- $base = $limits -}}
  {{- else -}}
    {{- $base = $preset.limitRange.limits | default list -}}
  {{- end -}}
{{- end -}}
{{- $out := $base -}}
{{- if $custom -}}
  {{- $out = concat $base $custom -}}
{{- end -}}
{{- toYaml $out -}}
{{- end }}

{{/*
Build RBAC Group subjects from .Values.groups (list of group name strings).
*/}}
{{- define "namespace-as-service.groupSubjects" -}}
{{- range .Values.groups }}
- kind: Group
  name: {{ . | quote }}
  apiGroup: rbac.authorization.k8s.io
{{- end }}
{{- end }}

{{- define "namespace-as-service.hasGroups" -}}
{{- gt (len (.Values.groups | default list)) 0 -}}
{{- end }}

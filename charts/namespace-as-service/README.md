# namespace-as-service

Multitenant Namespace-as-a-Service — workload namespaces, optional devops with namespaced Argo CD and Tekton RBAC, k* instance-size quotas.

![Version: 1.0.1-rc.1](https://img.shields.io/badge/Version-1.0.1--rc.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.1-rc.1](https://img.shields.io/badge/AppVersion-1.0.1--rc.1-informational?style=flat-square)

## Install

```bash
# Package from GitHub Packages (OCI)
helm install my-tenant oci://ghcr.io/ravichandrapatel/charts/namespace-as-service \
  --version <ver> -n <tenant>-devops --create-namespace -f values.yaml

# From this repo
helm dependency update charts/namespace-as-service
helm upgrade --install my-tenant ./charts/namespace-as-service \
  -n <tenant>-devops --create-namespace -f values.yaml
```

When `argocd.enabled=true`, install the release **into** `{tenant}-devops` so the namespaced Argo CD lands there.

## Features

- Multiple workload namespaces per tenant (`namespaces[].name`)
- Optional `{tenant}-devops` when `argocd.enabled` or `tekton.enabled`
- Default ResourceQuota/LimitRange from `instanceSize` (`kgen.medium`); presets live in `templates/_sizes.tpl` (not values)
- Optional per-NS `resourceQuota.hard` / `custom` overrides only when needed
- Hardcoded tenant Roles (groups via `groups` list only) — no ResourceQuota/LimitRange mutate
- Namespaced Argo CD (subchart) + Tekton pipeline SA/RBAC toggles

## Unit tests

```bash
helm dependency update charts/namespace-as-service
helm unittest charts/namespace-as-service --with-subchart=false
```

## Values

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| argocd.applicationSet.replicas | int | `1` |  |
| argocd.controller.replicas | int | `1` |  |
| argocd.controller.resources.limits.cpu | string | `"500m"` |  |
| argocd.controller.resources.limits.memory | string | `"512Mi"` |  |
| argocd.controller.resources.requests.cpu | string | `"100m"` |  |
| argocd.controller.resources.requests.memory | string | `"256Mi"` |  |
| argocd.crds.install | bool | `true` |  |
| argocd.createClusterRoles | bool | `false` |  |
| argocd.dex.enabled | bool | `false` |  |
| argocd.enabled | bool | `true` | Install namespaced Argo CD into devops (subchart alias; all Argo settings live here) |
| argocd.fullnameOverride | string | `"argocd"` |  |
| argocd.notifications.enabled | bool | `false` |  |
| argocd.redis-ha.enabled | bool | `false` |  |
| argocd.repoServer.replicas | int | `1` |  |
| argocd.repoServer.resources.limits.cpu | string | `"250m"` |  |
| argocd.repoServer.resources.limits.memory | string | `"256Mi"` |  |
| argocd.repoServer.resources.requests.cpu | string | `"50m"` |  |
| argocd.repoServer.resources.requests.memory | string | `"128Mi"` |  |
| argocd.server.ingress.enabled | bool | `false` |  |
| argocd.server.replicas | int | `1` |  |
| argocd.server.resources.limits.cpu | string | `"250m"` |  |
| argocd.server.resources.limits.memory | string | `"256Mi"` |  |
| argocd.server.resources.requests.cpu | string | `"50m"` |  |
| argocd.server.resources.requests.memory | string | `"128Mi"` |  |
| devops.instanceSize | string | `""` | Optional overrides for the auto-created {{tenant}}-devops namespace |
| devops.limitRange.customLimits | list | `[]` |  |
| devops.limitRange.limits | list | `[]` |  |
| devops.resourceQuota.custom | object | `{}` |  |
| devops.resourceQuota.hard | object | `{}` |  |
| extraObjects | list | `[]` | Extra Kubernetes manifests to render (tpl-evaluated). Each list item is a full object or multi-doc YAML string. |
| groups | list | `[]` | Entra / Okta / AD group names bound to hardcoded tenant Roles (all workload NS + devops) |
| instanceSize | string | `"kgen.medium"` | T-shirt size selector only (presets are hardcoded in templates/_sizes.tpl). Valid: kgen|km|kc|kgpu × medium|large|xlarge|2xlarge|4xlarge, or custom (+ resourceQuota.hard). |
| limitRange.enabled | bool | `true` | Create LimitRange objects |
| namespaceDefaults | object | `{"annotations":{},"labels":{}}` | Labels/annotations merged into every Namespace (workload + devops) |
| namespaces | list | `[]` | Workload namespaces (list of objects). Default: preset from instanceSize. Partial overlay: set resourceQuota.hard keys to merge onto the preset. Full custom (no default preset): instanceSize: custom  OR  resourceQuota.replace: true   and provide the complete resourceQuota.hard map (and limitRange.limits if limitRange.enabled). |
| networkPolicy.allowAllEgress | bool | `true` |  |
| networkPolicy.allowIngressFromSameNamespace | bool | `true` |  |
| networkPolicy.enabled | bool | `true` | Create NetworkPolicy objects |
| networkPolicy.policyTypes[0] | string | `"Ingress"` |  |
| networkPolicy.policyTypes[1] | string | `"Egress"` |  |
| resourceQuota.enabled | bool | `true` | Create ResourceQuota objects |
| tekton.enabled | bool | `true` | Create Tekton pipeline SA and RoleBindings (devops + deploy into each workload NS) |
| tekton.serviceAccount.name | string | `"pipeline"` |  |
| tenant | string | `""` | Tenant / product id. All namespaces[].name MUST start with "<tenant>-". Devops namespace is always "<tenant>-devops" when argocd/tekton is enabled. |

# namespace-as-service

[![CI](https://github.com/ravichandrapatel/namespace-as-service/actions/workflows/ci.yaml/badge.svg?branch=develop)](https://github.com/ravichandrapatel/namespace-as-service/actions/workflows/ci.yaml)
![Version](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square)
![Type](https://img.shields.io/badge/Type-application-informational?style=flat-square)

Multitenant **Namespace-as-a-Service** Helm chart for Kubernetes.

One release provisions **one tenant only**:

- One or more **workload namespaces** — each name MUST be `{tenant}-…` (e.g. `test-dev`, `test-uat`)
- Optional **`{tenant}-devops`** when `argocd.enabled` or `tekton.enabled` is true (auto-named; do not list it in `namespaces`)
- Mixing another product prefix (e.g. `payments-uat` under `tenant: test`) fails validation
- Default **ResourceQuota / LimitRange** from `instanceSize` (`kgen.medium` by default), overridable per namespace
- **Hardcoded** tenant RBAC (bind Entra/Okta/AD groups via `groups` only — no quota/limit mutate)
- Optional **namespaced Argo CD** in devops (all settings under one `argocd:` key via chart alias)
- Optional **Tekton** pipeline ServiceAccount + deploy RoleBindings into each workload namespace
- **extraObjects** for arbitrary additional manifests

## Quick start

```bash
helm dependency update charts/namespace-as-service

helm upgrade --install test ./charts/namespace-as-service \
  -n test-devops --create-namespace \
  -f examples/test-product.yaml
```

OCI install (after a release is published):

```bash
helm install test oci://ghcr.io/ravichandrapatel/charts/namespace-as-service \
  --version <version> \
  -n test-devops --create-namespace \
  -f examples/test-product.yaml
```

## Git branching model

Protected branches: **`main`**, **`develop`**, **`release/*`**.

```text
feature/* ──PR──► develop ──auto RC tag──► (prerelease)
                     │
                     └── cut release/X.Y.Z ──auto stable──► main
                                              └── bump develop → X.Y.(Z+1)-rc.1
```

### Daily development

```bash
git checkout develop
git pull
git checkout -b feature/my-change
# ... develop, commit, push ...
git push -u origin feature/my-change
# Open PR → develop (CI runs lint / unittest / helm-docs)
# Approve + merge
```

On merge to `develop`, **`release-rc`** automatically:

1. Bumps `Chart.yaml` (`1.0.0-rc.1` → `1.0.0-rc.2`, …)
2. Creates git tag `v…`
3. Publishes OCI chart + GitHub **prerelease**

Do **not** create tags manually.

### Stable release

When the RC line is ready (Chart on develop is e.g. `1.0.0-rc.N`):

```bash
git checkout develop
git pull
git checkout -b release/1.0.0
git push -u origin release/1.0.0
```

Branch name **must** be `release/X.Y.Z` matching the Chart base version (`1.0.0-rc.*` → `release/1.0.0`).

**`release-stable`** then automatically:

1. Sets version to stable `X.Y.Z`, tags `vX.Y.Z`, publishes OCI + GitHub **latest** release
2. Merges `release/X.Y.Z` → **`main`**
3. Merges into **`develop`** and bumps to **`X.Y.(Z+1)-rc.1`** for the next cycle

## Instance sizes

Families: `kgen` (general), `km` (memory), `kc` (compute), `kgpu` (GPU).  
Sizes: `medium` (default) → `large` → `xlarge` → `2xlarge` → `4xlarge` (presets in `templates/_sizes.tpl`).

| Goal | How |
| --- | --- |
| Default quota | omit `resourceQuota` (uses `instanceSize`, default `kgen.medium`) |
| Tweak a few keys | named size + `resourceQuota.hard` / `custom` (merged onto preset) |
| Fully custom (no default) | `instanceSize: custom` **or** `resourceQuota.replace: true` + full `resourceQuota.hard` |

See `examples/custom-quota.yaml` and [charts/namespace-as-service/README.md](charts/namespace-as-service/README.md).

## Develop locally

```bash
helm unittest charts/namespace-as-service --with-subchart=false
helm-docs -c charts/namespace-as-service -t charts/namespace-as-service/README.md.gotmpl
pre-commit install
```

## Access control

- **Owner only** (`@ravichandrapatel`): merge to protected branches, cut `release/*`, publish releases.
- **Everyone else**: view/clone only (open a fork PR if needed; owner merges after review).
- Branch rulesets on `main` / `develop`:
  - no force-push/delete, **require PR**, linear history, required `helm` CI
  - **≥1 approving review** + **CODEOWNERS** review (`@ravichandrapatel`)
  - **Bypass (always):** you (`@ravichandrapatel`) and repository Admins — merge without approval and skip rules when needed
- Branch rulesets on `release/*`: no force-push/delete (so you can cut `release/X.Y.Z` by push).
- `CHANGELOG.md` is **auto-generated** by `git-cliff` on every RC/stable release (`cliff.toml`).
- Release workflows commit as the owner. Set repo secret **`RELEASE_TOKEN`** (classic PAT: `repo` scope) so Actions can push version bumps when PR rules are enforced. Without it, workflows fall back to `GITHUB_TOKEN` (may fail under strict PR rules).

## Workflows

| Workflow | Trigger | Action |
| --- | --- | --- |
| `ci` | PR/push to `develop`, `main`, `release/**` | lint, unittest, docs drift |
| `release-rc` | push to `develop` (non-release / non-`[skip-release]`) | bump RC, regenerate CHANGELOG, tag + prerelease |
| `release-stable` | push to `release/X.Y.Z` | stable tag, CHANGELOG, merge `main`, bump `develop` |

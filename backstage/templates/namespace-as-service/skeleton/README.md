# ${{ values.tenant }} — Namespace as a Service

GitOps values scaffolded by the Backstage **Namespace as a Service** template.

## What this provisions

| Resource | Name |
| --- | --- |
| Workload namespaces | {% for env in values.environments }`${{ values.tenant }}-${{ env }}`{% if not loop.last %}, {% endif %}{% endfor %} |
| Devops namespace | {% if values.enableArgoCD or values.enableTekton }`${{ values.tenant }}-devops`{% else %}*(not created — Argo CD and Tekton disabled)*{% endif %} |
| Default size | `${{ values.instanceSize }}` |
| Chart version | `${{ values.chartVersion }}` |

## Install

```bash
helm install ${{ values.tenant }} oci://ghcr.io/ravichandrapatel/charts/namespace-as-service \
  --version ${{ values.chartVersion }} \
  -n ${{ values.tenant }}-devops --create-namespace \
  -f values.yaml
```

If both Argo CD and Tekton are disabled, pick any workload namespace as the release namespace (or create `${{ values.tenant }}-devops` yourself):

```bash
helm install ${{ values.tenant }} oci://ghcr.io/ravichandrapatel/charts/namespace-as-service \
  --version ${{ values.chartVersion }} \
  -n ${{ values.tenant }}-dev --create-namespace \
  -f values.yaml
```

## Argo CD Application (optional)

If you use a cluster-scoped Argo CD, apply:

```bash
kubectl apply -f argocd/application.yaml
```

## Docs

- Chart: https://github.com/ravichandrapatel/namespace-as-service
- Release: https://github.com/ravichandrapatel/namespace-as-service/releases/tag/v${{ values.chartVersion }}

# ${{ values.tenant }} NaaS

This repository was scaffolded from the Backstage **Namespace as a Service** template.

## Namespaces

{% for env in values.environments %}
- `${{ values.tenant }}-${{ env }}`
{% endfor %}
{% if values.enableArgoCD or values.enableTekton %}
- `${{ values.tenant }}-devops` (Argo CD / Tekton)
{% endif %}

## Install

See the repository [README](../README.md).

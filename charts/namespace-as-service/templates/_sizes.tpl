{{/*
Hardcoded t-shirt / instance size presets (chart contract — not in values.yaml).
Set instanceSize (e.g. kgen.medium) in values; optional resourceQuota.hard/custom overrides only.
*/}}
{{- define "namespace-as-service.sizes" -}}
kgen.medium:
  resourceQuota:
    hard:
      requests.cpu: "1"
      requests.memory: 2Gi
      limits.cpu: "2"
      limits.memory: 4Gi
      pods: "10"
      services: "10"
      persistentvolumeclaims: "3"
  limitRange:
    limits:
      - type: Container
        defaultRequest:
          cpu: "50m"
          memory: 64Mi
        default:
          cpu: "250m"
          memory: 256Mi
        max:
          cpu: "1"
          memory: 1Gi
kgen.large:
  resourceQuota:
    hard:
      requests.cpu: "2"
      requests.memory: 4Gi
      limits.cpu: "4"
      limits.memory: 8Gi
      pods: "20"
      services: "10"
      persistentvolumeclaims: "6"
  limitRange:
    limits:
      - type: Container
        defaultRequest:
          cpu: "50m"
          memory: 64Mi
        default:
          cpu: "250m"
          memory: 256Mi
        max:
          cpu: "2"
          memory: 2Gi
kgen.xlarge:
  resourceQuota:
    hard:
      requests.cpu: "4"
      requests.memory: 8Gi
      limits.cpu: "8"
      limits.memory: 16Gi
      pods: "40"
      services: "10"
      persistentvolumeclaims: "12"
  limitRange:
    limits:
      - type: Container
        defaultRequest:
          cpu: "50m"
          memory: 64Mi
        default:
          cpu: "250m"
          memory: 256Mi
        max:
          cpu: "4"
          memory: 4Gi
kgen.2xlarge:
  resourceQuota:
    hard:
      requests.cpu: "8"
      requests.memory: 16Gi
      limits.cpu: "16"
      limits.memory: 32Gi
      pods: "80"
      services: "10"
      persistentvolumeclaims: "24"
  limitRange:
    limits:
      - type: Container
        defaultRequest:
          cpu: "50m"
          memory: 64Mi
        default:
          cpu: "250m"
          memory: 256Mi
        max:
          cpu: "8"
          memory: 8Gi
kgen.4xlarge:
  resourceQuota:
    hard:
      requests.cpu: "16"
      requests.memory: 32Gi
      limits.cpu: "32"
      limits.memory: 64Gi
      pods: "160"
      services: "10"
      persistentvolumeclaims: "48"
  limitRange:
    limits:
      - type: Container
        defaultRequest:
          cpu: "50m"
          memory: 64Mi
        default:
          cpu: "250m"
          memory: 256Mi
        max:
          cpu: "16"
          memory: 16Gi
km.medium:
  resourceQuota:
    hard:
      requests.cpu: "1"
      requests.memory: 8Gi
      limits.cpu: "2"
      limits.memory: 16Gi
      pods: "8"
      services: "10"
      persistentvolumeclaims: "4"
  limitRange:
    limits:
      - type: Container
        defaultRequest:
          cpu: "50m"
          memory: 256Mi
        default:
          cpu: "250m"
          memory: 1Gi
        max:
          cpu: "1"
          memory: 4Gi
km.large:
  resourceQuota:
    hard:
      requests.cpu: "2"
      requests.memory: 16Gi
      limits.cpu: "4"
      limits.memory: 32Gi
      pods: "16"
      services: "10"
      persistentvolumeclaims: "8"
  limitRange:
    limits:
      - type: Container
        defaultRequest:
          cpu: "50m"
          memory: 256Mi
        default:
          cpu: "250m"
          memory: 1Gi
        max:
          cpu: "2"
          memory: 8Gi
km.xlarge:
  resourceQuota:
    hard:
      requests.cpu: "4"
      requests.memory: 32Gi
      limits.cpu: "8"
      limits.memory: 64Gi
      pods: "32"
      services: "10"
      persistentvolumeclaims: "16"
  limitRange:
    limits:
      - type: Container
        defaultRequest:
          cpu: "50m"
          memory: 256Mi
        default:
          cpu: "250m"
          memory: 1Gi
        max:
          cpu: "4"
          memory: 16Gi
km.2xlarge:
  resourceQuota:
    hard:
      requests.cpu: "8"
      requests.memory: 64Gi
      limits.cpu: "16"
      limits.memory: 128Gi
      pods: "64"
      services: "10"
      persistentvolumeclaims: "32"
  limitRange:
    limits:
      - type: Container
        defaultRequest:
          cpu: "50m"
          memory: 256Mi
        default:
          cpu: "250m"
          memory: 1Gi
        max:
          cpu: "8"
          memory: 32Gi
km.4xlarge:
  resourceQuota:
    hard:
      requests.cpu: "16"
      requests.memory: 128Gi
      limits.cpu: "32"
      limits.memory: 256Gi
      pods: "128"
      services: "10"
      persistentvolumeclaims: "64"
  limitRange:
    limits:
      - type: Container
        defaultRequest:
          cpu: "50m"
          memory: 256Mi
        default:
          cpu: "250m"
          memory: 1Gi
        max:
          cpu: "16"
          memory: 64Gi
kc.medium:
  resourceQuota:
    hard:
      requests.cpu: "4"
      requests.memory: 2Gi
      limits.cpu: "8"
      limits.memory: 4Gi
      pods: "10"
      services: "10"
      persistentvolumeclaims: "3"
  limitRange:
    limits:
      - type: Container
        defaultRequest:
          cpu: "100m"
          memory: 64Mi
        default:
          cpu: "500m"
          memory: 256Mi
        max:
          cpu: "2"
          memory: 1Gi
kc.large:
  resourceQuota:
    hard:
      requests.cpu: "8"
      requests.memory: 4Gi
      limits.cpu: "16"
      limits.memory: 8Gi
      pods: "20"
      services: "10"
      persistentvolumeclaims: "6"
  limitRange:
    limits:
      - type: Container
        defaultRequest:
          cpu: "100m"
          memory: 64Mi
        default:
          cpu: "500m"
          memory: 256Mi
        max:
          cpu: "4"
          memory: 2Gi
kc.xlarge:
  resourceQuota:
    hard:
      requests.cpu: "16"
      requests.memory: 8Gi
      limits.cpu: "32"
      limits.memory: 16Gi
      pods: "40"
      services: "10"
      persistentvolumeclaims: "12"
  limitRange:
    limits:
      - type: Container
        defaultRequest:
          cpu: "100m"
          memory: 64Mi
        default:
          cpu: "500m"
          memory: 256Mi
        max:
          cpu: "8"
          memory: 4Gi
kc.2xlarge:
  resourceQuota:
    hard:
      requests.cpu: "32"
      requests.memory: 16Gi
      limits.cpu: "64"
      limits.memory: 32Gi
      pods: "80"
      services: "10"
      persistentvolumeclaims: "24"
  limitRange:
    limits:
      - type: Container
        defaultRequest:
          cpu: "100m"
          memory: 64Mi
        default:
          cpu: "500m"
          memory: 256Mi
        max:
          cpu: "16"
          memory: 8Gi
kc.4xlarge:
  resourceQuota:
    hard:
      requests.cpu: "64"
      requests.memory: 32Gi
      limits.cpu: "128"
      limits.memory: 64Gi
      pods: "160"
      services: "10"
      persistentvolumeclaims: "48"
  limitRange:
    limits:
      - type: Container
        defaultRequest:
          cpu: "100m"
          memory: 64Mi
        default:
          cpu: "500m"
          memory: 256Mi
        max:
          cpu: "32"
          memory: 16Gi
kgpu.medium:
  resourceQuota:
    hard:
      requests.cpu: "2"
      requests.memory: 8Gi
      limits.cpu: "4"
      limits.memory: 16Gi
      pods: "5"
      services: "10"
      persistentvolumeclaims: "3"
      requests.nvidia.com/gpu: "1"
      limits.nvidia.com/gpu: "1"
  limitRange:
    limits:
      - type: Container
        defaultRequest:
          cpu: "100m"
          memory: 512Mi
        default:
          cpu: "500m"
          memory: 2Gi
        max:
          cpu: "2"
          memory: 4Gi
          nvidia.com/gpu: "1"
kgpu.large:
  resourceQuota:
    hard:
      requests.cpu: "4"
      requests.memory: 16Gi
      limits.cpu: "8"
      limits.memory: 32Gi
      pods: "10"
      services: "10"
      persistentvolumeclaims: "6"
      requests.nvidia.com/gpu: "2"
      limits.nvidia.com/gpu: "2"
  limitRange:
    limits:
      - type: Container
        defaultRequest:
          cpu: "100m"
          memory: 512Mi
        default:
          cpu: "500m"
          memory: 2Gi
        max:
          cpu: "4"
          memory: 8Gi
          nvidia.com/gpu: "2"
kgpu.xlarge:
  resourceQuota:
    hard:
      requests.cpu: "8"
      requests.memory: 32Gi
      limits.cpu: "16"
      limits.memory: 64Gi
      pods: "20"
      services: "10"
      persistentvolumeclaims: "12"
      requests.nvidia.com/gpu: "4"
      limits.nvidia.com/gpu: "4"
  limitRange:
    limits:
      - type: Container
        defaultRequest:
          cpu: "100m"
          memory: 512Mi
        default:
          cpu: "500m"
          memory: 2Gi
        max:
          cpu: "8"
          memory: 16Gi
          nvidia.com/gpu: "4"
kgpu.2xlarge:
  resourceQuota:
    hard:
      requests.cpu: "16"
      requests.memory: 64Gi
      limits.cpu: "32"
      limits.memory: 128Gi
      pods: "40"
      services: "10"
      persistentvolumeclaims: "24"
      requests.nvidia.com/gpu: "8"
      limits.nvidia.com/gpu: "8"
  limitRange:
    limits:
      - type: Container
        defaultRequest:
          cpu: "100m"
          memory: 512Mi
        default:
          cpu: "500m"
          memory: 2Gi
        max:
          cpu: "16"
          memory: 32Gi
          nvidia.com/gpu: "8"
kgpu.4xlarge:
  resourceQuota:
    hard:
      requests.cpu: "32"
      requests.memory: 128Gi
      limits.cpu: "64"
      limits.memory: 256Gi
      pods: "80"
      services: "10"
      persistentvolumeclaims: "48"
      requests.nvidia.com/gpu: "16"
      limits.nvidia.com/gpu: "16"
  limitRange:
    limits:
      - type: Container
        defaultRequest:
          cpu: "100m"
          memory: 512Mi
        default:
          cpu: "500m"
          memory: 2Gi
        max:
          cpu: "32"
          memory: 64Gi
          nvidia.com/gpu: "16"
{{- end }}

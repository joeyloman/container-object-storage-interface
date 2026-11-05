# container-object-storage-interface

Helm chart for the Container Object Storage Interface (COSI) core controller and
the `objectstorage.k8s.io` CRDs. COSI drivers are distributed separately and are
not part of this chart.

## Install

```sh
helm install cosi oci://harbor.lab.atmosbv.nl/atmos-helm-charts/container-object-storage-interface \
  --version 0.2.2 \
  --namespace container-object-storage-system --create-namespace
```

From a checkout:

```sh
helm install cosi ./charts/container-object-storage-interface \
  --namespace container-object-storage-system --create-namespace
```

The controller image defaults to the Kubernetes staging registry tag pinned by
this repository's kustomize manifests. Override it for a release or mirrored
image:

```sh
helm install cosi ./charts/container-object-storage-interface \
  --namespace container-object-storage-system --create-namespace \
  --set image.repository=registry.example.com/objectstorage-controller \
  --set image.tag=v0.2.2
```

## CRDs

The CRDs live in `crds/` and are installed by Helm before any other resource.
Helm never upgrades or deletes files in `crds/`, so apply CRD updates before
upgrading the chart:

```sh
kubectl apply --server-side -f charts/container-object-storage-interface/crds/
helm upgrade cosi ./charts/container-object-storage-interface \
  --namespace container-object-storage-system
```

`make helm-crds` regenerates and copies the CRDs from `client/config/crd`.

## Metrics

Metrics are disabled by default. When enabled with `metrics.secure=true` (the
default), the controller serves HTTPS with a self-signed certificate and
authorizes scrapes with TokenReview/SubjectAccessReview; the chart adds those
RBAC rules. The scraping identity still needs cluster RBAC for the
`/metrics` nonResourceURL, for example:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: cosi-metrics-reader
rules:
  - nonResourceURLs: ["/metrics"]
    verbs: ["get"]
```

`metrics.serviceMonitor.enabled=true` creates a Prometheus Operator
`ServiceMonitor`; the Prometheus service account must be bound to a role like the
one above.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| `image.repository` | string | `gcr.io/k8s-staging-sig-storage/objectstorage-controller` | Controller image repository |
| `image.tag` | string | staging tag pinned by this repo | Controller image tag |
| `image.pullPolicy` | string | `IfNotPresent` | Image pull policy |
| `imagePullSecrets` | list | `[]` | Pull secrets for the controller pod |
| `replicaCount` | int | `1` | Controller replicas; leader election keeps one active |
| `leaderElection.enabled` | bool | `true` | Enable leader election and the leases Role/RoleBinding |
| `logLevel` | string | `info` | `--zap-log-level` |
| `development` | bool | `false` | `--zap-devel`; `false` emits JSON logs |
| `extraArgs` | list | `[]` | Additional controller arguments |
| `healthProbe.port` | int | `8081` | Health probe port (`/healthz`, `/readyz`) |
| `metrics.enabled` | bool | `false` | Serve the metrics endpoint |
| `metrics.secure` | bool | `true` | Serve metrics over HTTPS with authn/authz |
| `metrics.port` | int | `8443` | Metrics container and Service port |
| `metrics.service.type` | string | `ClusterIP` | Metrics Service type |
| `metrics.serviceMonitor.enabled` | bool | `false` | Create a Prometheus Operator ServiceMonitor |
| `metrics.serviceMonitor.insecureSkipVerify` | bool | `true` | Skip verification of the self-signed metrics certificate |
| `serviceAccount.create` | bool | `true` | Create the controller ServiceAccount |
| `serviceAccount.name` | string | `""` | ServiceAccount name; defaults to the chart fullname |
| `serviceAccount.annotations` | map | `{}` | ServiceAccount annotations |
| `rbac.create` | bool | `true` | Create ClusterRole, ClusterRoleBinding, Role, RoleBinding |
| `podAnnotations` | map | `{}` | Pod annotations |
| `podLabels` | map | `{}` | Additional pod labels |
| `podSecurityContext` | map | nonroot, RuntimeDefault seccomp | Pod security context |
| `securityContext` | map | read-only rootfs, no capabilities | Container security context |
| `resources` | map | `{}` | Controller resource requests/limits |
| `nodeSelector` | map | `{}` | Pod node selector |
| `tolerations` | list | `[]` | Pod tolerations |
| `affinity` | map | `{}` | Pod affinity |
| `priorityClassName` | string | `""` | Pod priority class |
| `terminationGracePeriodSeconds` | int | `10` | Pod termination grace period |

## Uninstall

```sh
helm uninstall cosi --namespace container-object-storage-system
```

CRDs and existing COSI custom resources are retained. Delete them explicitly if
that is intended:

```sh
kubectl delete -f charts/container-object-storage-interface/crds/
```

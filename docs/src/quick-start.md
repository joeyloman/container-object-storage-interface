# Quick Start

COSI components are out-of-tree and need manual installation.

To install COSI Custom Resource Definitions and COSI Controller with kustomize, issue the following command:

```sh
kubectl apply -k 'https://github.com/kubernetes-sigs/container-object-storage-interface//?ref=release-0.2'
```

Alternatively, install both with Helm from a checkout of this repository:

```sh
helm install cosi ./charts/container-object-storage-interface \
  --namespace container-object-storage-system --create-namespace
```

The chart installs the CRDs from its `crds/` directory and the controller
Deployment, ServiceAccount, and RBAC. See the
[chart README](https://github.com/kubernetes-sigs/container-object-storage-interface/tree/main/charts/container-object-storage-interface)
for values, CRD upgrade steps, and metrics configuration.

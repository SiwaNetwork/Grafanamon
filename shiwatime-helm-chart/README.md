# SHIWA TIME Management Platform Helm Chart

## Overview

SHIWA TIME is a modern metrics collection and monitoring platform, providing a complete out-of-the-box deployment with Elasticsearch for data storage and Grafana for visualization.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure (for persistence)
- MetalLB configured (for LoadBalancer services)

## Installation

### Quick Install (Recommended Method)

The following commands will set up SHIWA TIME on your system using MicroK8s:

```bash
# Install snapd (if not already installed)
sudo dnf install -y snapd
sudo ln -s /var/lib/snapd/snap /snap

# Install MicroK8s
sudo snap install microk8s --classic

# Enable required addons
sudo /snap/bin/microk8s enable dns
sudo /snap/bin/microk8s enable hostpath-storage
sudo /snap/bin/microk8s enable helm3
sudo /snap/bin/microk8s enable metallb

# When prompted for IP address range, enter in format: IPaddress-IPaddress
# Example: 10.101.101.101-10.101.101.101

# Add SHIWA TIME Helm repository
sudo /snap/bin/microk8s helm3 repo add shiwatime https://charts.shiwatime.io/
sudo /snap/bin/microk8s helm3 repo update

# Install SHIWA TIME
sudo /snap/bin/microk8s helm3 install shiwatime shiwatime/shiwatime-backend-chart
```

### Standard Kubernetes Installation

If you're using a standard Kubernetes cluster:

```bash
# Add SHIWA TIME Helm repository
helm repo add shiwatime https://charts.shiwatime.io/
helm repo update

# Install SHIWA TIME
helm install shiwatime shiwatime/shiwatime-backend-chart
```

### Custom Installation

To customize the installation, create a `values.yaml` file:

```yaml
elasticsearch:
  resources:
    requests:
      memory: "4Gi"
      cpu: "2000m"

grafana:
  adminPassword: "your-secure-password"
  persistence:
    size: 20Gi

branding:
  companyName: "Your Company"
  supportEmail: "support@yourcompany.com"
```

Then install with:

```bash
helm install shiwatime shiwatime/shiwatime-backend-chart -f values.yaml
```

## Accessing SHIWA TIME

Once the installation is complete:

1. **Elasticsearch** will be available on port 9200
2. **Grafana** will be available on port 80

Default login credentials for Grafana:
- Username: `admin`
- Password: `admin` (you'll be prompted to change this on first login)

To get the service IPs:

```bash
# For MicroK8s
sudo /snap/bin/microk8s kubectl get svc

# For standard Kubernetes
kubectl get svc
```

## Configuration

### Key Configuration Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| `elasticsearch.enabled` | Enable Elasticsearch | `true` |
| `elasticsearch.replicas` | Number of Elasticsearch replicas | `1` |
| `elasticsearch.resources` | Resource requests/limits | See values.yaml |
| `grafana.enabled` | Enable Grafana | `true` |
| `grafana.adminUser` | Grafana admin username | `admin` |
| `grafana.adminPassword` | Grafana admin password | `admin` |
| `grafana.persistence.enabled` | Enable persistent storage | `true` |
| `grafana.persistence.size` | PVC size for Grafana | `10Gi` |

### Storage Classes

By default, the chart uses `microk8s-hostpath` storage class. To use a different storage class:

```yaml
global:
  storageClass: "your-storage-class"
```

## Upgrading

To upgrade SHIWA TIME to the latest version:

```bash
# For MicroK8s
sudo /snap/bin/microk8s helm3 repo update
sudo /snap/bin/microk8s helm3 upgrade shiwatime shiwatime/shiwatime-backend-chart

# For standard Kubernetes
helm repo update
helm upgrade shiwatime shiwatime/shiwatime-backend-chart
```

## Monitoring

Check the deployment status:

```bash
# For MicroK8s
sudo /snap/bin/microk8s kubectl get all --all-namespaces

# For standard Kubernetes
kubectl get all --all-namespaces
```

## Uninstalling

To remove SHIWA TIME:

```bash
# For MicroK8s
sudo /snap/bin/microk8s helm3 uninstall shiwatime

# For standard Kubernetes
helm uninstall shiwatime
```

To completely reset MicroK8s (removes all data):

```bash
sudo /snap/bin/microk8s reset
```

## Troubleshooting

### Services not accessible

1. Check if all pods are running:
   ```bash
   kubectl get pods
   ```

2. Check service endpoints:
   ```bash
   kubectl get endpoints
   ```

3. Check MetalLB configuration:
   ```bash
   kubectl get configmap -n metallb-system
   ```

### Pods stuck in Pending state

This usually indicates storage issues. Check:

1. Storage class availability:
   ```bash
   kubectl get storageclass
   ```

2. PVC status:
   ```bash
   kubectl get pvc
   ```

## Support

For support and questions:
- Email: support@shiwatime.io
- Documentation: https://docs.shiwatime.io
- Issues: https://github.com/shiwatime/helm-charts/issues

## License

Copyright 2024 SHIWA TIME Team. Licensed under Apache License 2.0.
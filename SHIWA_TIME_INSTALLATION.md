# SHIWA TIME Management Platform - Installation Guide

![SHIWA TIME Logo](https://shiwatime.io/logo.png)

## 🚀 Quick Installation (Recommended)

SHIWA TIME is a modern metrics collection and monitoring platform that provides a complete out-of-the-box deployment with Elasticsearch for data storage and Grafana for visualization.

### One-Command Installation

Copy and paste these commands to install SHIWA TIME on your system:

```bash
# Install prerequisites
sudo dnf install -y snapd
sudo ln -s /var/lib/snapd/snap /snap

# Install MicroK8s
sudo snap install microk8s --classic

# Enable required components
sudo /snap/bin/microk8s enable dns
sudo /snap/bin/microk8s enable hostpath-storage
sudo /snap/bin/microk8s enable helm3
sudo /snap/bin/microk8s enable metallb

# IMPORTANT: When prompted for IP address range, enter in format:
# IPaddress-IPaddress (e.g., 10.101.101.101-10.101.101.101)

# Add SHIWA TIME repository and install
sudo /snap/bin/microk8s helm3 repo add shiwatime https://charts.shiwatime.io/
sudo /snap/bin/microk8s helm3 install shiwatime shiwatime/shiwatime-backend-chart
```

## 📊 Accessing SHIWA TIME

Once installation is complete:

### Elasticsearch
- **Port**: 9200
- **URL**: `http://<your-ip>:9200`

### Grafana Dashboard
- **Port**: 80
- **URL**: `http://<your-ip>:80`
- **Default Username**: admin
- **Default Password**: admin
- ⚠️ You will be prompted to change the password on first login

## 🔧 Post-Installation

### Check Deployment Status

```bash
sudo /snap/bin/microk8s kubectl get all --all-namespaces
```

The output should show all SHIWA TIME components running:
- shiwatime-elasticsearch (StatefulSet)
- shiwatime-grafana (Deployment)
- Associated services and pods

### Get Service IPs

```bash
sudo /snap/bin/microk8s kubectl get svc
```

## 🔄 Updates

To update SHIWA TIME to the latest version:

```bash
sudo /snap/bin/microk8s helm3 repo update
sudo /snap/bin/microk8s helm3 upgrade shiwatime shiwatime/shiwatime-backend-chart
```

## 🛑 Managing SHIWA TIME

### Stop Services
```bash
sudo /snap/bin/microk8s stop
```

### Start Services
```bash
sudo /snap/bin/microk8s start
```

### Uninstall SHIWA TIME
```bash
sudo /snap/bin/microk8s helm3 uninstall shiwatime
```

### Complete System Reset
```bash
sudo /snap/bin/microk8s reset
```

## 🎨 Features

### Pre-configured Components
- **Elasticsearch 7.17.9** - High-performance data storage
- **Grafana 9.4.7** - Beautiful visualization dashboards
- **Custom SHIWA TIME Dashboards** - Ready-to-use monitoring panels
- **Automatic Data Retention** - 30-day default retention policy
- **Persistent Storage** - Data survives restarts

### SHIWA TIME Branding
- Custom loading screens
- Branded login pages
- SHIWA TIME themed dashboards
- Professional color scheme

## 📋 System Requirements

- **OS**: Linux (RHEL/CentOS/Fedora/Ubuntu)
- **RAM**: Minimum 4GB (8GB recommended)
- **Storage**: 20GB free space minimum
- **CPU**: 2 cores minimum (4 recommended)
- **Network**: Static IP recommended

## 🔍 Troubleshooting

### Services Not Accessible

1. Check pod status:
```bash
sudo /snap/bin/microk8s kubectl get pods
```

2. View logs:
```bash
# Elasticsearch logs
sudo /snap/bin/microk8s kubectl logs -l app.kubernetes.io/component=elasticsearch

# Grafana logs
sudo /snap/bin/microk8s kubectl logs -l app.kubernetes.io/component=grafana
```

### IP Address Issues

If you need to reconfigure MetalLB:
```bash
sudo /snap/bin/microk8s disable metallb
sudo /snap/bin/microk8s enable metallb
# Enter your IP range when prompted
```

## 📞 Support

- **Email**: support@shiwatime.io
- **Documentation**: https://docs.shiwatime.io
- **Community**: https://community.shiwatime.io

## 🏆 Why SHIWA TIME?

- **Easy Installation**: Deploy in minutes with a single command
- **Production Ready**: Enterprise-grade components pre-configured
- **Beautiful UI**: Modern, responsive dashboards
- **Scalable**: Grow from single node to cluster deployment
- **Open Standards**: Built on Elasticsearch and Grafana

---

**SHIWA TIME** - Modern Metrics Collection Made Simple

© 2024 SHIWA TIME Team. Licensed under Apache License 2.0.
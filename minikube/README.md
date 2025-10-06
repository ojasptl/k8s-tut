# Minikube Setup

This directory contains scripts for setting up a local Kubernetes cluster using Minikube.

## Files Overview

### 1. `minikube_install.sh`
This script installs Minikube on your system. Here's the detailed explanation:

```bash
# Download Minikube binary
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# Make it executable and move to path
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

The installation process:
1. Downloads the latest Minikube binary for Linux AMD64
2. Installs it to `/usr/local/bin` for system-wide access

## Usage Instructions

1. **Install Minikube:**
   ```bash
   ./minikube_install.sh
   ```

2. **Start Minikube:**
   ```bash
   minikube start
   ```

3. **Verify Installation:**
   ```bash
   minikube status
   ```

## Common Minikube Operations

1. **Start Cluster:**
   ```bash
   minikube start
   ```

2. **Stop Cluster:**
   ```bash
   minikube stop
   ```

3. **Delete Cluster:**
   ```bash
   minikube delete
   ```

4. **Access Dashboard:**
   ```bash
   minikube dashboard
   ```

5. **Enable Addons:**
   ```bash
   minikube addons list
   minikube addons enable <addon-name>
   ```

## Differences from Kind
- Minikube is designed for local development
- Typically runs a single-node cluster
- Includes built-in dashboard
- Provides various VM drivers (VirtualBox, KVM, etc.)

## Notes
- Requires virtualization support
- Good for local development and testing
- Includes useful developer features like automatic image loading
- Suitable for learning Kubernetes basics
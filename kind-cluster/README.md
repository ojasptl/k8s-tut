# Kind Cluster Setup

This directory contains configuration and setup scripts for creating and managing a Kubernetes cluster using Kind (Kubernetes in Docker).

## Files Overview

### 1. `kind_install.sh`
This script installs Kind on your system. Here's what it does:

```bash
# Installation command for Kind
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

The script:
1. Downloads the appropriate Kind binary for Linux AMD64 architecture
2. Makes the binary executable
3. Moves it to `/usr/local/bin` for system-wide access

### 2. `kind_cluster_init.sh`
This script initializes a Kind cluster using the configuration specified in `config.yaml`. 

```bash
#!/bin/bash
kind create cluster --config config.yaml
```

The script:
1. Creates a new Kind cluster
2. Uses the configuration specified in `config.yaml`
3. Sets up the cluster with the defined specifications

### 3. `config.yaml`
This file contains the cluster configuration:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
```

The configuration:
1. Defines a cluster with 3 nodes:
   - One control plane node (master)
   - Two worker nodes
2. Uses the Kind API version `v1alpha4`
3. Creates a multi-node cluster setup for testing distributed applications

## Usage Instructions

1. **Install Kind:**
   ```bash
   ./kind_install.sh
   ```

2. **Create Cluster:**
   ```bash
   ./kind_cluster_init.sh
   ```

3. **Verify Cluster:**
   ```bash
   kubectl get nodes
   ```
   This should show three nodes: one control-plane and two workers.

## Common Operations

1. **Delete Cluster:**
   ```bash
   kind delete cluster
   ```

2. **Get Clusters:**
   ```bash
   kind get clusters
   ```

3. **Access Cluster:**
   ```bash
   kubectl cluster-info --context kind-kind
   ```

## Notes
- The cluster uses Docker as its container runtime
- The configuration creates a production-like environment with multiple nodes
- Suitable for testing Kubernetes features like pod scheduling and node affinity
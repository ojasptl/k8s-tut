# Kubernetes Tutorial Project (k8s-tut)

This repository contains a comprehensive set of Kubernetes examples and setup scripts, demonstrating various Kubernetes concepts and deployments.

## Project Structure

```
.
├── kind-cluster/           # Kind cluster setup and configuration
│   ├── config.yaml        # Kind cluster configuration
│   ├── kind_install.sh    # Script to install Kind
│   └── kind_cluster_init.sh # Script to initialize Kind cluster
├── minikube/
│   └── minikube_install.sh # Script to install Minikube
└── nginx/                  # NGINX-based examples and deployments
    ├── namespace.yaml     # NGINX namespace definition
    ├── pod.yaml          # Basic NGINX pod configuration
    ├── deployment.yaml   # NGINX deployment configuration
    ├── deployment_script.sh # Script for managing deployments
    ├── replicasets.yaml  # ReplicaSet configuration
    ├── replica_scripts.sh # Scripts for managing ReplicaSets
    ├── daemonsets.yaml   # DaemonSet configuration
    ├── daemonsets.sh     # Scripts for managing DaemonSets
    ├── jobs.yaml         # Job configuration
    ├── jobs_script.sh    # Scripts for managing Jobs
    ├── cron-job.yaml     # CronJob configuration
    ├── persistantVolume.yaml # PersistentVolume configuration
    ├── persistant-volumes-claim.yaml # PVC configuration
    └── persistent_volume.sh # Scripts for managing PVs and PVCs
```

## Features

1. **Cluster Setup Options**
   - Kind cluster setup and configuration
   - Minikube installation and setup

2. **NGINX Deployments**
   - Basic pod deployment
   - Multi-replica deployments
   - ReplicaSet management
   - DaemonSet configuration
   - Job and CronJob examples

3. **Storage Management**
   - PersistentVolume configuration
   - PersistentVolumeClaim setup

## Key Components

### Kind Cluster Setup
- `kind-cluster/kind_install.sh`: Script for installing Kind
- `kind-cluster/kind_cluster_init.sh`: Initializes a Kind cluster
- `kind-cluster/config.yaml`: Cluster configuration

### NGINX Examples
1. **Basic Deployments**
   - `nginx/namespace.yaml`: Creates NGINX namespace
   - `nginx/pod.yaml`: Single pod deployment
   - `nginx/deployment.yaml`: Multi-pod deployment configuration

2. **Advanced Configurations**
   - `nginx/replicasets.yaml`: Manages pod replicas
   - `nginx/daemonsets.yaml`: Runs pods on all nodes
   - `nginx/jobs.yaml`: One-time job execution
   - `nginx/cron-job.yaml`: Scheduled backup job

3. **Storage Configuration**
   - `nginx/persistantVolume.yaml`: Defines persistent storage
   - `nginx/persistant-volumes-claim.yaml`: Claims storage for pods

### Management Scripts
- Deployment management: `nginx/deployment_script.sh`
- ReplicaSet management: `nginx/replica_scripts.sh`
- DaemonSet management: `nginx/daemonsets.sh`
- Job management: `nginx/jobs_script.sh`
- Volume management: `nginx/persistent_volume.sh`

## Getting Started

1. **Setup Cluster**
   ```bash
   # Using Kind
   cd kind-cluster
   ./kind_install.sh
   ./kind_cluster_init.sh

   # OR using Minikube
   cd minikube
   ./minikube_install.sh
   ```

2. 1. **Deploy NGINX Examples**
   ```bash
   cd nginx
   kubectl apply -f namespace.yaml
   kubectl apply -f deployment.yaml
   ```
   2. **To start the service**
   ```
   kubectl apply -f service.yaml
   ```
3. **To get all services, deployments, etc**
   ```
   kubectl get all -n nginx
   ```
4. **To forward the port of docker container for accessing the service use the below**
   ```
   sudo -E kubectl port-forward service/nginx-service -n nginx 81:80 --address=0.0.0.0
   ```
   ### If command giving error without the
   ```
   sudo -E
   ```

## Prerequisites
- Docker
- kubectl
- Either Kind or Minikube

## License
This project is open-source and available under the MIT License.

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.
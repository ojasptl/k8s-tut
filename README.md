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
├── ingress/               # Ingress controller setup and examples
│   ├── ingress_setup.sh   # Script to deploy NGINX Ingress Controller
│   └── ingress-example.yaml # Example Ingress resource
├── mysql/                  # MySQL StatefulSet examples
│   ├── statefulsets.yaml  # MySQL StatefulSet configuration
│   ├── mysql-service.yaml # Headless service for StatefulSet
│   └── mysql_stateful_demo.sh # Demo script for StatefulSets
├── configmaps/             # ConfigMap examples and guides
│   ├── configmap-example.yaml  # Example ConfigMap definitions
│   ├── configmap-usage-pod.yaml # Pod using ConfigMaps
│   └── configmap-demo.sh   # Demo script for ConfigMaps
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

4. **Ingress Controller**
   - NGINX Ingress Controller deployment
   - Ingress resource configuration
   - URL-based routing

5. **StatefulSet Applications**
   - MySQL database deployment
   - Persistent storage for stateful apps
   - Headless services for direct pod access
   - Watch command for real-time monitoring
   
6. **Configuration Management**
   - ConfigMaps for application configuration
   - Multiple creation methods (files, literals, directories)
   - Environment variables and volume mounts
   - Dynamic configuration updates

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

### Ingress Controller Setup
- `ingress/ingress_setup.sh`: Deploys NGINX Ingress Controller for Kind
- `ingress/ingress-example.yaml`: Example Ingress configuration
- `ingress/README.md`: Detailed explanation of Ingress concepts

### StatefulSet Examples
- `mysql/statefulsets.yaml`: MySQL StatefulSet deployment with persistent storage
- `mysql/mysql-service.yaml`: Headless service for StatefulSet DNS
- `mysql/README.md`: Comprehensive guide to StatefulSets and watch commands

### Configuration Management
- `configmaps/configmap-example.yaml`: Various ConfigMap definition examples
- `configmaps/configmap-usage-pod.yaml`: Pod demonstrating ConfigMap consumption
- `configmaps/README.md`: Detailed guide on ConfigMap creation and usage

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

5. **Deploy Ingress Controller (for Kind)**
   ```bash
   cd ingress
   chmod +x ingress_setup.sh
   ./ingress_setup.sh
   
   # Apply example ingress
   kubectl apply -f ingress-example.yaml
   ```

6. **Configure Ingress for Multiple Services**
   ```bash
   cd nginx
   kubectl apply -f ingress.yaml
   
   # Port-forward the ingress controller
   kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80
   
   # Access services through ingress
   curl http://localhost:8080/nginx
   curl http://localhost:8080/app
   ```

7. **Deploy Stateful Applications with MySQL**
   ```bash
   cd mysql
   
   # Create namespace and deploy StatefulSet
   kubectl create namespace mysql
   kubectl apply -f statefulsets.yaml
   
   # Watch pods being created in real-time
   kubectl get pods -n mysql -w
   
   # Deploy headless service for StatefulSet
   kubectl apply -f mysql-service.yaml
   
   # Connect to a specific MySQL instance
   kubectl exec -it mysql-statefulset-0 -n mysql -- mysql -uroot -proot
   ```
   
8. **Work with ConfigMaps**
   ```bash
   cd configmaps
   
   # Create ConfigMap from YAML
   kubectl apply -f configmap-example.yaml
   
   # Create ConfigMap from literal values
   kubectl create configmap literal-config \
     --from-literal=api.url=https://api.example.com \
     --from-literal=max.items=100
     
   # Create ConfigMap from file
   echo "server.port=8080" > config.properties
   kubectl create configmap file-config --from-file=config.properties
   
   # Deploy a pod that uses the ConfigMap
   kubectl apply -f configmap-usage-pod.yaml
   
   # View ConfigMap contents
   kubectl describe configmap app-config
   ```

## Prerequisites
- Docker
- kubectl
- Either Kind or Minikube

## License
This project is open-source and available under the MIT License.

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.
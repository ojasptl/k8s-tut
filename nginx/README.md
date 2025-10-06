# NGINX Kubernetes Examples

This directory contains various Kubernetes configurations and scripts demonstrating different Kubernetes concepts using NGINX. Each configuration is explained in detail with its purpose, components, and how they work together in a Kubernetes environment.

## Kubernetes Concepts Explained

Before diving into specific files, let's understand some key Kubernetes concepts:

1. **Namespace**: A virtual cluster inside your Kubernetes cluster
2. **Pod**: The smallest deployable unit in Kubernetes
3. **Deployment**: Manages the deployment and scaling of Pods
4. **ReplicaSet**: Ensures a specified number of Pod replicas are running
5. **DaemonSet**: Ensures all nodes run a copy of a Pod
6. **Job/CronJob**: Manages task-based and scheduled workloads
7. **PersistentVolume/PVC**: Manages storage in Kubernetes

## Files Overview

### Basic Setup

#### 1. `namespace.yaml`
Creates a dedicated namespace for NGINX resources:
```yaml
kind: Namespace    # Defines the resource type as Namespace
apiVersion: v1     # Uses the core v1 API group
metadata: 
   name: nginx     # Name of the namespace to be created
```

**Detailed Explanation:**
- **Why Namespace?**: Namespaces provide isolation between resources. They help:
  - Avoid naming conflicts between teams
  - Set resource quotas per project/team
  - Organize resources logically
  - Control access and permissions

**Commands and Their Purpose:**
```bash
# Create the namespace
kubectl apply -f namespace.yaml

# Verify namespace creation
kubectl get namespace nginx

# View detailed namespace information
kubectl describe namespace nginx
```

**Expected Outcomes:**
- Creates an isolated environment named 'nginx'
- All resources with `namespace: nginx` will be created in this namespace
- Resources in different namespaces can have the same name without conflicts

#### 2. `pod.yaml`
Defines a basic NGINX pod:
```yaml
apiVersion: v1          # Uses the core v1 API group
kind: Pod               # Defines this as a Pod resource
metadata:
  name: nginx-pod       # Name of the pod
  namespace: nginx      # Namespace where pod will be created
spec:
  containers:           # List of containers in the pod
  - name: nginx        # Name of the container
    image: nginx:latest # Docker image to use
    ports:             # Port configurations
    - containerPort: 80 # Port that NGINX listens on
```

**Detailed Explanation:**
- **Why Pods?**: Pods are the smallest deployable units in Kubernetes:
  - Can contain one or more containers
  - Share the same network namespace
  - Can communicate via localhost
  - Are ephemeral (temporary)

**Each Field Explained:**
1. `apiVersion: v1`: Uses the core Kubernetes API
2. `metadata`: 
   - `name`: Unique identifier for the pod
   - `namespace`: Logical isolation group
3. `spec.containers`:
   - `name`: Container identifier within pod
   - `image`: Docker image for NGINX
   - `ports`: Network ports to expose
   
**Commands and Their Purpose:**
```bash
# Create the pod
kubectl apply -f pod.yaml

# Check pod status
kubectl get pods -n nginx

# View pod details
kubectl describe pod nginx-pod -n nginx

# Access pod logs
kubectl logs nginx-pod -n nginx

# Execute commands in pod
kubectl exec -it nginx-pod -n nginx -- bash
```

**Expected Outcomes:**
- Creates a single NGINX pod
- NGINX server running on port 80
- Pod gets a unique IP within the cluster
- Can be accessed by other pods in the cluster

### Deployment Management

#### 1. `deployment.yaml`
Manages multiple NGINX pods with rolling updates:
```yaml
kind: Deployment        # Defines this as a Deployment resource
apiVersion: apps/v1     # Uses the apps API group
metadata:
  name: nginx-deployment # Name of the deployment
  namespace: nginx      # Namespace for the deployment
spec:
  replicas: 2          # Number of pod replicas to maintain
  selector:            # How the deployment finds pods to manage
    matchLabels:       # Must match template labels
      app: nginx
  template:            # Template for creating pods
    metadata:
      labels:          # Labels for the pods
        app: nginx     # Must match selector
    spec:
      containers:
        - name: nginx  # Container name
          image: nginx:latest # Image to use
          ports:       # Port configuration
          - containerPort: 80 # NGINX default port
```

**Detailed Explanation:**
- **Why Deployments?**: Deployments provide:
  - Declarative updates for Pods
  - Rolling updates and rollbacks
  - Scaling capabilities
  - Self-healing through ReplicaSets

**Each Field Explained:**
1. `apiVersion: apps/v1`: Uses the apps API group for advanced resources
2. `spec.replicas`: Number of identical pods to maintain
3. `spec.selector`: How deployment identifies its pods
   - Must match template labels
   - Enables pod management and scaling
4. `spec.template`: Pod template
   - Defines pod configuration
   - Used when creating new pods

**Deployment Strategy:**
```yaml
  strategy:
    type: RollingUpdate    # Default update strategy
    rollingUpdate:
      maxSurge: 25%        # Max extra pods during update
      maxUnavailable: 25%  # Max unavailable pods during update
```

**Commands and Their Purpose:**
```bash
# Create/Update deployment
kubectl apply -f deployment.yaml

# Check deployment status
kubectl get deployments -n nginx

# View deployment details
kubectl describe deployment nginx-deployment -n nginx

# Scale deployment
kubectl scale deployment nginx-deployment --replicas=3 -n nginx

# Rollout history
kubectl rollout history deployment nginx-deployment -n nginx

# Rollback deployment
kubectl rollout undo deployment nginx-deployment -n nginx
```

**Expected Outcomes:**
- Creates and maintains specified number of NGINX pods
- Automatically replaces failed pods
- Enables easy scaling up/down
- Supports zero-downtime updates
- Maintains application availability

#### 2. `deployment_script.sh`
Script for managing deployments:
- Creates deployments
- Scales replicas
- Performs rolling updates
- Monitors deployment status

### ReplicaSet Management

#### 1. `replicasets.yaml`
Maintains a specified number of pod replicas:
```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-replicaset
  namespace: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
```

#### 2. `replica_scripts.sh`
Scripts for:
- Creating ReplicaSets
- Scaling replicas
- Monitoring pod status

### DaemonSet Configuration

#### 1. `daemonsets.yaml`
Runs NGINX pod on every node:
```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx-daemonset
  namespace: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:latest
```

#### 2. `daemonsets.sh`
Scripts for:
- Managing DaemonSets
- Updating configurations
- Monitoring node coverage

### Jobs and CronJobs

#### 1. `jobs.yaml`
One-time task execution:
```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: nginx-job
  namespace: nginx
spec:
  template:
    spec:
      containers:
      - name: nginx
        image: nginx:latest
      restartPolicy: Never
```

#### 2. `cron-job.yaml`
Scheduled backup task:
```yaml
kind: CronJob
apiVersion: batch/v1
metadata:
  name: minute-backup
  namespace: nginx
spec:
  schedule: "* * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: backup-container
              image: busybox:latest
              command: 
                - sh
                - -c
                - echo "Backup Started"; mkdir -p /backups && mkdir -p /demo-data && cp -r /demo-data /backups && echo "Backup Completed"
```

### Storage Configuration

#### 1. `persistantVolume.yaml`
Defines persistent storage:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: nginx-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/mnt/data"
```

#### 2. `persistant-volumes-claim.yaml`
Claims storage for pods:
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nginx-pvc
  namespace: nginx
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

## Tutorial Walkthrough

1. **Create Namespace:**
   ```bash
   kubectl apply -f namespace.yaml
   ```

2. **Basic Pod Deployment:**
   ```bash
   kubectl apply -f pod.yaml
   kubectl get pods -n nginx
   ```

3. **Scale with Deployment:**
   ```bash
   kubectl apply -f deployment.yaml
   kubectl get deployments -n nginx
   ```

4. **Set Up ReplicaSet:**
   ```bash
   kubectl apply -f replicasets.yaml
   kubectl get rs -n nginx
   ```

5. **Configure DaemonSet:**
   ```bash
   kubectl apply -f daemonsets.yaml
   kubectl get ds -n nginx
   ```

6. **Run Jobs:**
   ```bash
   kubectl apply -f jobs.yaml
   kubectl get jobs -n nginx
   ```

7. **Schedule CronJobs:**
   ```bash
   kubectl apply -f cron-job.yaml
   kubectl get cronjobs -n nginx
   ```

8. **Set Up Storage:**
   ```bash
   kubectl apply -f persistantVolume.yaml
   kubectl apply -f persistant-volumes-claim.yaml
   kubectl get pv,pvc -n nginx
   ```

## Common Operations

1. **Check Resources:**
   ```bash
   kubectl get all -n nginx
   ```

2. **View Logs:**
   ```bash
   kubectl logs <pod-name> -n nginx
   ```

3. **Describe Resource:**
   ```bash
   kubectl describe <resource-type> <resource-name> -n nginx
   ```

4. **Delete Resources:**
   ```bash
   kubectl delete -f <filename.yaml>
   ```

## Notes
- All resources are created in the `nginx` namespace
- Examples demonstrate progressive complexity
- Includes both stateless and stateful deployments
- Covers main Kubernetes resource types
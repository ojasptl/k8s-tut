# MySQL StatefulSets in Kubernetes

This directory contains configurations for deploying MySQL databases using Kubernetes StatefulSets. StatefulSets are essential for stateful applications like databases that require stable network identities and persistent storage.

## Understanding StatefulSets

StatefulSets are designed for applications that require one or more of the following:

1. **Stable, unique network identifiers**
2. **Stable, persistent storage**
3. **Ordered, graceful deployment and scaling**
4. **Ordered, automated rolling updates**

Unlike Deployments, StatefulSets maintain a sticky identity for each pod. These pods are created from the same spec, but are not interchangeable: each has a persistent identifier that it maintains across any rescheduling.

## Files Overview

### 1. `statefulsets.yaml`

This file defines a MySQL StatefulSet with 3 replicas:

```yaml
kind: StatefulSet
apiVersion: apps/v1
metadata:
  name: mysql-statefulset
  namespace: mysql
spec:
  serviceName: mysql-service
  replicas: 3
  selector:
    matchLabels:
      app: mysql
  template:
    metadata:
      labels:
        app: mysql
    spec:
      containers:
        - name: mysql
          image: mysql:8.0
          ports: 
          - containerPort: 3306
          env:
          - name: MYSQL_ROOT_PASSWORD
            value: root
          - name: MYSQL_DATABASE
            value: devops
          volumeMounts:
          - name: mysql-data
            mountPath: /var/lib/mysql
  volumeClaimTemplates:
  - metadata:
      name: mysql-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 1Gi
```

### Key Components Explained:

1. **serviceName**: 
   - Defines the name of the headless service that controls the network domain
   - Required for StatefulSets to work properly

2. **replicas**: 
   - Number of identical pods to deploy (3 in this case)
   - Each gets a unique name and identity

3. **volumeClaimTemplates**: 
   - Creates a PersistentVolumeClaim for each pod automatically
   - Ensures each pod gets its own storage that persists across restarts
   - Critical for data persistence in databases

4. **podManagementPolicy** (not shown, defaults to OrderedReady):
   - Controls how pods are created and terminated
   - OrderedReady: sequential creation/termination (0, 1, 2...)
   - Parallel: pods created/terminated in parallel

5. **updateStrategy** (not shown, defaults to RollingUpdate):
   - Defines how pods are updated when the StatefulSet spec changes
   - RollingUpdate: updates pods one at a time
   - OnDelete: requires manual deletion to trigger update

## MySQL Service Configuration

For a complete MySQL setup, you should create a headless service. Create a file called `mysql-service.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: mysql-service
  namespace: mysql
spec:
  clusterIP: None  # Headless service
  selector:
    app: mysql
  ports:
  - port: 3306
    targetPort: 3306
```

A headless service (with `clusterIP: None`) enables direct access to individual pods using DNS records in the format:
`<pod-name>.<service-name>.<namespace>.svc.cluster.local`

For example:
- mysql-statefulset-0.mysql-service.mysql.svc.cluster.local
- mysql-statefulset-1.mysql-service.mysql.svc.cluster.local
- mysql-statefulset-2.mysql-service.mysql.svc.cluster.local

## The `kubectl watch` Command

The `kubectl watch` command is invaluable for monitoring StatefulSet creation and updates. It provides real-time visibility into changes as they happen.

### Basic Syntax:
```bash
kubectl get [resource] -w
```
The `-w` or `--watch` flag enables watch functionality.

### Examples:

1. **Watch StatefulSet deployment:**
   ```bash
   kubectl get statefulset -n mysql -w
   ```
   This shows real-time changes to the StatefulSet as pods are created or updated.

2. **Watch pods being created:**
   ```bash
   kubectl get pods -n mysql -w
   ```
   This shows pods being created sequentially with status changes.

3. **Watch persistent volume claims:**
   ```bash
   kubectl get pvc -n mysql -w
   ```
   This shows PVCs being created and bound to PVs.

4. **Watch with custom columns:**
   ```bash
   kubectl get pods -n mysql -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName -w
   ```
   This shows more detailed information while watching.

5. **Watch with wide output:**
   ```bash
   kubectl get pods -n mysql -o wide -w
   ```
   This includes additional information like node and IP addresses.

### Why Watch is Essential for StatefulSets:

1. **Sequential Deployment Validation:**
   - StatefulSets deploy pods in order (0, 1, 2...)
   - Watch helps confirm proper sequential creation

2. **Troubleshooting:**
   - Immediately see if pods fail to start
   - Identify issues with storage provisioning

3. **Scaling Operations:**
   - Monitor orderly scale-up/down operations
   - Ensure volumes are correctly attached/detached

4. **Update Rollouts:**
   - Watch rolling updates as they progress through pods
   - Verify each pod updates successfully before proceeding to next

## Usage Instructions

1. **Create the namespace:**
   ```bash
   kubectl create namespace mysql
   ```

2. **Deploy the MySQL StatefulSet:**
   ```bash
   kubectl apply -f statefulsets.yaml
   ```

3. **Monitor the StatefulSet creation:**
   ```bash
   kubectl get pods -n mysql -w
   ```
   You'll see pods being created one by one, in order.

4. **Create the headless service:**
   ```bash
   kubectl apply -f mysql-service.yaml
   ```

5. **Verify StatefulSet is running:**
   ```bash
   kubectl get statefulset -n mysql
   ```

6. **Connect to a specific MySQL instance:**
   ```bash
   kubectl exec -it mysql-statefulset-0 -n mysql -- mysql -uroot -proot
   ```

## StatefulSet Operations

### Scaling:
```bash
kubectl scale statefulset mysql-statefulset -n mysql --replicas=5
```

### Deleting:
```bash
kubectl delete statefulset mysql-statefulset -n mysql
```
Note: This won't delete the PVCs by default, preserving your data.

### Updating:
```bash
kubectl apply -f updated-statefulsets.yaml
```
The update will roll out one pod at a time.

## Best Practices for MySQL StatefulSets

1. **Use a headless service** for direct pod addressing
2. **Configure proper resource limits** for MySQL containers
3. **Set up liveness and readiness probes** for MySQL
4. **Use secrets for passwords** instead of environment variables
5. **Configure init containers** for database initialization
6. **Set up proper backup strategies** for the PVCs
7. **Consider using a MySQL operator** for complex setups

## Understanding Kubernetes DNS for StatefulSets

The DNS entries for StatefulSet pods follow this pattern:
```
<pod-name>.<service-name>.<namespace>.svc.cluster.local
```

For MySQL replication, you can use these DNS names to configure master/slave relationships.

## Troubleshooting

1. **Pods stuck in Pending:**
   - Check if PVs are available
   - Verify storage class exists

2. **MySQL not starting:**
   - Check logs: `kubectl logs mysql-statefulset-0 -n mysql`
   - Verify environment variables

3. **Cannot connect to MySQL:**
   - Check service: `kubectl get svc mysql-service -n mysql`
   - Verify pod is running: `kubectl get pod mysql-statefulset-0 -n mysql`

4. **Data loss after restart:**
   - Check if PVCs were deleted
   - Verify PVC is bound: `kubectl get pvc -n mysql`
# Kubernetes ConfigMaps

This directory contains examples and explanations of Kubernetes ConfigMaps, a resource type that allows you to decouple configuration from container images.

## What are ConfigMaps?

ConfigMaps are API objects that store non-confidential data as key-value pairs. Pods can consume ConfigMaps as:
- Environment variables
- Command-line arguments
- Configuration files in a volume

Using ConfigMaps allows you to separate your configurations from your application code, following the Twelve-Factor App methodology for configuration management.

## When to Use ConfigMaps

Use ConfigMaps for:
- Application configuration files
- Environment-specific settings
- Non-sensitive parameters
- Feature flags
- Resource locations (URLs, file paths)

Do NOT use ConfigMaps for:
- Sensitive data (use Secrets instead)
- Large files (>1MB)
- Binary data (use Secrets with binary encoding)

## Files Overview

### 1. `configmap-example.yaml`

This file demonstrates different ways to define ConfigMap data:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: default
data:
  # Simple key-value pairs
  database_url: "mysql:3306"
  api_endpoint: "https://api.example.com"
  
  # Config files as multi-line strings
  app.properties: |
    server.port=8080
    spring.application.name=MyApp
    logging.level.root=INFO
    
  # Environment-specific configuration
  dev.properties: |
    mode=development
    debug=true
    
  prod.properties: |
    mode=production
    debug=false
```

### 2. `configmap-usage-pod.yaml`

This file demonstrates how to use ConfigMaps in a Pod:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: configmap-pod
spec:
  containers:
    - name: app
      image: nginx:alpine
      # Mount config as volume
      volumeMounts:
        - name: config-volume
          mountPath: /etc/config
      # Use config as environment variables
      env:
        - name: DATABASE_URL
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: database_url
      # Load all ConfigMap keys as environment variables
      envFrom:
        - configMapRef:
            name: app-config
  volumes:
    - name: config-volume
      configMap:
        name: app-config
```

## Creating ConfigMaps

### 1. From YAML File

```bash
kubectl apply -f configmap-example.yaml
```

### 2. From Literal Values

```bash
kubectl create configmap literal-config \
  --from-literal=api.url=https://api.example.com \
  --from-literal=max.items=100
```

### 3. From a File

```bash
# Create a properties file
echo "port=8080" > config.properties

# Create ConfigMap from file
kubectl create configmap file-config --from-file=config.properties
```

### 4. From Multiple Files in a Directory

```bash
# Create config files
mkdir -p config-dir
echo "db.host=mysql" > config-dir/db.properties
echo "cache.ttl=300" > config-dir/cache.properties

# Create ConfigMap from directory
kubectl create configmap dir-config --from-file=config-dir/
```

## Using ConfigMaps

### 1. As Environment Variables

Three different ways to use ConfigMaps as environment variables:

#### a. Single Environment Variable
```yaml
env:
  - name: DATABASE_URL
    valueFrom:
      configMapKeyRef:
        name: app-config
        key: database_url
```

#### b. All Keys as Environment Variables
```yaml
envFrom:
  - configMapRef:
      name: app-config
```

#### c. Environment Variable with Default Value
```yaml
env:
  - name: DATABASE_URL
    valueFrom:
      configMapKeyRef:
        name: app-config
        key: database_url
        optional: true  # Won't fail if missing
```

### 2. As Volume Mounts

#### a. Mount Entire ConfigMap
```yaml
volumes:
  - name: config-volume
    configMap:
      name: app-config
volumeMounts:
  - name: config-volume
    mountPath: /etc/config
```

This creates a file for each key in the ConfigMap at `/etc/config/key-name`.

#### b. Mount Specific Items
```yaml
volumes:
  - name: config-volume
    configMap:
      name: app-config
      items:
        - key: app.properties
          path: application.properties
volumeMounts:
  - name: config-volume
    mountPath: /etc/app-config
```

This creates only the specified file at `/etc/app-config/application.properties`.

### 3. As Command Arguments

```yaml
command: ["java", "-jar", "app.jar"]
args: ["--spring.config.location=/etc/config/app.properties"]
volumeMounts:
  - name: config-volume
    mountPath: /etc/config
volumes:
  - name: config-volume
    configMap:
      name: app-config
```

## ConfigMap Best Practices

1. **Keep ConfigMaps Small**
   - Split large configurations into multiple ConfigMaps
   - Group related configurations together

2. **Use Namespaces**
   - Keep ConfigMaps in the same namespace as the pods that use them

3. **Label ConfigMaps**
   - Add labels to categorize and filter ConfigMaps
   - Example: `environment: dev`, `app: frontend`

4. **Version Control**
   - Store ConfigMap YAML files in your Git repository
   - Document each configuration option

5. **Atomic Updates**
   - Update entire ConfigMaps rather than individual keys
   - Consider impacts on running applications

6. **Consider Immutability**
   - Create new ConfigMaps rather than modifying existing ones
   - Use naming conventions to indicate versions

## Understanding ConfigMap Updates

When a ConfigMap is updated:

1. Volume-mounted ConfigMaps:
   - Updates propagate automatically after a delay (up to 1 minute)
   - No pod restart required

2. Environment variables from ConfigMaps:
   - Updates don't propagate automatically
   - Require pod restart to pick up changes

## Dynamic ConfigMap Reloading

For applications that need real-time configuration updates:

1. **Use Volume Mounts** instead of environment variables
2. **Configure Your Application** to watch for file changes
3. **Consider Using a Configuration Service** like Spring Cloud Config or Consul

Example applications that support dynamic reloading:
- Spring Boot with Spring Cloud Kubernetes
- Nginx with nginx-reload sidecar
- Custom applications with inotify-based file watchers

## Commands to Work with ConfigMaps

1. **List ConfigMaps**
   ```bash
   kubectl get configmaps
   ```

2. **Describe ConfigMap**
   ```bash
   kubectl describe configmap app-config
   ```

3. **Edit ConfigMap**
   ```bash
   kubectl edit configmap app-config
   ```

4. **Get ConfigMap in YAML format**
   ```bash
   kubectl get configmap app-config -o yaml
   ```

5. **Delete ConfigMap**
   ```bash
   kubectl delete configmap app-config
   ```

6. **Create ConfigMap from file**
   ```bash
   kubectl create configmap app-config --from-file=config.properties
   ```

## Comparing ConfigMaps and Secrets

| Feature | ConfigMaps | Secrets |
|---------|------------|---------|
| Purpose | Store non-confidential data | Store sensitive data |
| Storage | Stored unencrypted | Base64 encoded (not encrypted) |
| Size limit | 1MB | 1MB |
| Usage | Environment vars, files | Environment vars, files |
| Display | Visible in plain text | Obscured in kubectl output |

## Practical Example

1. **Create a ConfigMap**
   ```bash
   kubectl apply -f configmap-example.yaml
   ```

2. **Deploy a pod using the ConfigMap**
   ```bash
   kubectl apply -f configmap-usage-pod.yaml
   ```

3. **Verify the ConfigMap is mounted**
   ```bash
   kubectl exec configmap-pod -- ls -la /etc/config
   ```

4. **View the contents of mounted files**
   ```bash
   kubectl exec configmap-pod -- cat /etc/config/app.properties
   ```

5. **Check environment variables**
   ```bash
   kubectl exec configmap-pod -- env | grep DATABASE_URL
   ```
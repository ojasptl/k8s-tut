# Kubernetes Ingress Controller Setup

This directory contains configuration and scripts for setting up and using the NGINX Ingress Controller in Kubernetes.

## What is an Ingress Controller?

An Ingress Controller is a specialized load balancer for Kubernetes that operates at the application layer (Layer 7). It allows you to:

- Route external HTTP/HTTPS traffic to internal services
- Implement name-based virtual hosting
- Set up URL path-based routing
- Terminate TLS/SSL
- Implement rate limiting, authentication, etc.

## Files Overview

### 1. `ingress_setup.sh`

This script deploys the NGINX Ingress Controller in your Kubernetes cluster:

```bash
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
```

**Detailed Explanation:**

- The command applies a collection of Kubernetes manifests that deploy:
  - Namespace for ingress-nginx
  - ServiceAccount, ConfigMap, and Roles
  - Deployment for the NGINX Ingress Controller
  - Service to expose the Ingress Controller

- **Why use this specific manifest?**
  - It's specifically configured for Kind clusters
  - Handles port bindings correctly for containerized environments
  - Sets up appropriate node selectors and tolerations
  - Configures the controller with Kind-specific settings

### 2. `ingress-example.yaml`

This file provides an example of how to use Ingress to route traffic:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingress
  namespace: nginx
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: nginx.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: nginx-service
            port:
              number: 80
```

**How Ingress Rules Work:**
- `host`: Specifies the domain name (virtual host) for this rule
- `paths`: URL paths that should be routed
- `backend`: Defines which service and port traffic should be directed to

## Path Types and Routing Strategies

Kubernetes Ingress supports different path types for routing:

### 1. **Prefix Pathtype**
```yaml
pathType: Prefix
path: /app
```
- Routes all traffic with URLs starting with the specified prefix
- Example: `/app`, `/app/`, `/app/users`, etc.
- Simple but limited for complex routing needs

### 2. **Exact Pathtype**
```yaml
pathType: Exact
path: /app
```
- Only matches the exact path specified
- Example: Only `/app` will match, but not `/app/` or `/app/users`
- Useful for precise endpoint control

### 3. **ImplementationSpecific Pathtype**
```yaml
pathType: ImplementationSpecific
path: /app
```
- Behavior depends on IngressClass controller
- With NGINX, can be used with regex annotations
- Most flexible option for complex routing

## Path Rewriting with Annotations

### Simple Root Rewriting
```yaml
annotations:
  nginx.ingress.kubernetes.io/rewrite-target: /
```
- Rewrites ALL paths to the root path `/`
- Example: `/app/users` → `/` (loses path information)
- Simple but limited - good for single-page applications

### Pattern-Based Rewriting
```yaml
annotations:
  nginx.ingress.kubernetes.io/use-regex: "true"
  nginx.ingress.kubernetes.io/rewrite-target: /$1
path: /app/(.*)
```
- Captures parts of the URL with regex groups
- Example: `/app/users` → `/users`
- Preserves path information after the prefix

### Advanced Regex Patterns
```yaml
annotations:
  nginx.ingress.kubernetes.io/use-regex: "true"
  nginx.ingress.kubernetes.io/rewrite-target: /$2
path: /app(/|$)(.*)
```
- Handles trailing slashes correctly
- `/app` → `/`
- `/app/` → `/`
- `/app/users` → `/users`

## Multiple Services Example
The advanced ingress configuration used in this project:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-notes-ingress
  namespace: nginx
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
    - http:
        paths:
          - pathType: Prefix
            path: /nginx
            backend:
              service:
                name: nginx-service
                port: 
                  number: 80
          - pathType: Prefix
            path: /app
            backend:
              service:
                name: notes-app-service
                port: 
                  number: 8000
```

**Key points:**
1. Routes `/nginx` to nginx-service
2. Routes `/app` to notes-app-service
3. Rewrites all paths to `/` (root path)

## Common Troubleshooting

### 404 Errors for Subpaths
If your application can access `/app` but not `/app/users`:

1. **Check rewrite configuration**:
   ```yaml
   nginx.ingress.kubernetes.io/rewrite-target: /$2
   path: /app(/|$)(.*)
   ```

2. **Verify application routing**:
   - Ensure your app can handle the rewritten paths
   - Check if your app's router is properly configured

3. **Test path directly**:
   ```bash
   kubectl port-forward svc/your-service -n namespace 8000:8000
   curl localhost:8000/users  # Test direct access
   ```

### Path Rewriting Debugging Tips

1. **Check ingress controller logs**:
   ```bash
   kubectl logs -n ingress-nginx deployment/ingress-nginx-controller
   ```

2. **Add debug headers**:
   ```yaml
   nginx.ingress.kubernetes.io/configuration-snippet: |
     add_header X-Debug-Path $request_uri;
   ```

3. **Test with curl**:
   ```bash
   curl -v http://localhost/app/users
   ```

## Usage Instructions

1. **Deploy the NGINX Ingress Controller:**
   ```bash
   chmod +x ingress_setup.sh
   ./ingress_setup.sh
   ```

2. **Create the Ingress Resource:**
   ```bash
   kubectl apply -f ingress-example.yaml
   ```

3. **Verify Ingress is Working:**
   ```bash
   kubectl get ingress -n nginx
   ```

4. **Port-Forward the Ingress Controller:**
   ```bash
   kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80
   ```

5. **Access Your Services:**
   ```bash
   # Access nginx service
   curl http://localhost:8080/nginx
   
   # Access notes-app service
   curl http://localhost:8080/app
   ```

## Notes
- An Ingress Controller is required for Ingress resources to work
- Ingress resources won't function without an Ingress Controller installed
- Kind requires a specific Ingress Controller configuration for proper port binding
- Consider using Prefix paths with simple rewrites for beginners
- For complex applications, use regex patterns with capture groups
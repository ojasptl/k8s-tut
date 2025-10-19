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

4. **Access the Application:**

   For Kind clusters, you can access the application using:
   ```bash
   # Get the ingress controller's NodePort
   kubectl get service -n ingress-nginx
   
   # Access your service (replace with your port and host)
   curl -H "Host: nginx.example.com" http://localhost:80
   ```

## Common Use Cases

1. **Multiple Services on the Same Domain:**
   ```yaml
   spec:
     rules:
     - host: example.com
       http:
         paths:
         - path: /app1
           backend: {service: app1-service, port: 80}
         - path: /app2
           backend: {service: app2-service, port: 80}
   ```

2. **Multiple Domains (Virtual Hosting):**
   ```yaml
   spec:
     rules:
     - host: service1.example.com
       http: # service1 backend config
     - host: service2.example.com
       http: # service2 backend config
   ```

3. **TLS/SSL Configuration:**
   ```yaml
   spec:
     tls:
     - hosts:
       - secure.example.com
       secretName: tls-secret
   ```

## Notes
- An Ingress Controller is required for Ingress resources to work
- Ingress resources won't function without an Ingress Controller installed
- Kind requires a specific Ingress Controller configuration for proper port binding
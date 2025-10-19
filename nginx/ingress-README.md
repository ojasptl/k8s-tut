# Ingress Configuration for NGINX Services

This directory contains an ingress configuration file (`ingress.yaml`) that demonstrates how to route traffic to multiple services using the NGINX Ingress Controller.

## Ingress YAML Explanation

The `ingress.yaml` file contains the following configuration:

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

### Key Components:

1. **Metadata Section**:
   - `name`: The name of the ingress resource
   - `namespace`: Specifies the namespace (nginx in this case)
   - `annotations`: Contains configuration directives for the ingress controller

2. **Annotations**:
   - `nginx.ingress.kubernetes.io/rewrite-target: /`: This annotation rewrites all incoming paths to the root path `/` when forwarded to the backend service

3. **Rules and Paths**:
   - Two path configurations that route traffic based on URL path:
     - `/nginx` → routes to nginx-service on port 80
     - `/app` → routes to notes-app-service on port 8000

4. **PathType: Prefix**:
   - Matches URLs that start with the specified path
   - For example, `/nginx`, `/nginx/`, `/nginx/index.html` all match the `/nginx` path prefix

## Usage

1. **Deploy the Ingress Controller** (if not already deployed):
   ```bash
   kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml
   ```

2. **Apply the Ingress Configuration**:
   ```bash
   kubectl apply -f ingress.yaml
   ```

3. **Verify Ingress Resource**:
   ```bash
   kubectl get ingress -n nginx
   ```

4. **Access the Services**:
   ```bash
   # Port-forward the ingress controller
   kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 8080:80
   
   # Access NGINX service
   curl http://localhost:8080/nginx
   
   # Access Notes app service
   curl http://localhost:8080/app
   ```

## Path Rewriting

The `rewrite-target: /` annotation in this configuration rewrites all paths to `/`, which means:

- When you access `/nginx`, the request is forwarded to nginx-service as `/`
- When you access `/app`, the request is forwarded to notes-app-service as `/`

This is useful for services that expect to be accessed at the root path, but it can cause issues with subpaths. For applications that need to preserve subpath information, you can use regex-based path rewriting:

```yaml
annotations:
  nginx.ingress.kubernetes.io/use-regex: "true"
  nginx.ingress.kubernetes.io/rewrite-target: /$2
path: /app(/|$)(.*)
```

This would rewrite `/app/users` to `/users` instead of just `/`.

## Common Issues and Solutions

1. **404 Not Found for Subpaths**:
   - Check if the rewrite rule is appropriate for your application
   - Verify if your application can handle the rewritten paths
   - Consider using regex-based path rewriting to preserve path information

2. **CSS/JS Not Loading**:
   - Check if your application uses relative or absolute paths for resources
   - Adjust rewrite rules accordingly

3. **Multiple Paths for Same Service**:
   - You can add multiple path entries for the same backend service
   - Useful for applications that need to be accessed via different paths

## More Information

For more detailed information about Ingress controllers and path routing strategies, refer to the `/ingress/README.md` file in this repository.
#!/bin/bash

# This script deploys the NGINX Ingress Controller for Kind
# The NGINX Ingress Controller allows routing external traffic to Kubernetes services

echo "🚀 Deploying NGINX Ingress Controller for Kind..."

# Apply the official NGINX Ingress Controller manifest for Kind
kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml

# Wait for ingress controller to be ready
echo "⏳ Waiting for NGINX Ingress Controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

echo "✅ NGINX Ingress Controller deployment complete!"
echo ""
echo "📝 You can now create Ingress resources to route traffic to your services."
echo "Example usage:"
echo "  kubectl apply -f ingress-example.yaml"


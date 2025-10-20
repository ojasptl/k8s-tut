#!/bin/bash

# This script demonstrates creating and using ConfigMaps in Kubernetes

echo "🔧 ConfigMap Demo Script 🔧"
echo "=========================="

# 1. Create ConfigMap from literal values
echo -e "\n📝 Creating ConfigMap from literal values..."
kubectl create configmap literal-config \
  --from-literal=api.url=https://api.example.com \
  --from-literal=max.items=100

# 2. Create a properties file
echo -e "\n📝 Creating properties file..."
mkdir -p temp-configs
echo "server.port=8080" > temp-configs/server.properties
echo "app.name=MyApplication" >> temp-configs/server.properties
echo "logging.level=INFO" >> temp-configs/server.properties

# 3. Create ConfigMap from file
echo -e "\n📝 Creating ConfigMap from file..."
kubectl create configmap file-config --from-file=temp-configs/server.properties

# 4. Create multiple files for directory-based ConfigMap
echo "cache.ttl=300" > temp-configs/cache.properties
echo "cache.max-size=1000" >> temp-configs/cache.properties
echo "db.url=jdbc:mysql://localhost:3306/mydb" > temp-configs/database.properties
echo "db.username=dbuser" >> temp-configs/database.properties

# 5. Create ConfigMap from directory
echo -e "\n📝 Creating ConfigMap from directory..."
kubectl create configmap dir-config --from-file=temp-configs/

# 6. Apply the example ConfigMap from YAML
echo -e "\n📝 Creating ConfigMap from YAML file..."
kubectl apply -f configmap-example.yaml

# 7. List all ConfigMaps
echo -e "\n📋 Listing all ConfigMaps:"
kubectl get configmaps

# 8. Describe one of the ConfigMaps
echo -e "\n🔍 Describing ConfigMap 'app-config':"
kubectl describe configmap app-config

# 9. Apply the pod that uses the ConfigMap
echo -e "\n🚀 Creating pod that uses ConfigMap..."
kubectl apply -f configmap-usage-pod.yaml

# 10. Wait for pod to be ready
echo -e "\n⏳ Waiting for pod to be ready..."
kubectl wait --for=condition=Ready pod/configmap-pod --timeout=60s

# 11. Verify environment variables from ConfigMap
echo -e "\n🔍 Checking environment variables in pod:"
kubectl exec configmap-pod -- env | grep -E 'DATABASE_URL|API_ENDPOINT'

# 12. Verify mounted files from ConfigMap
echo -e "\n🔍 Checking mounted files in pod:"
kubectl exec configmap-pod -- ls -la /etc/config

# 13. View content of a config file
echo -e "\n🔍 Viewing content of app.properties:"
kubectl exec configmap-pod -- cat /etc/config/app.properties

# Clean up temporary files
echo -e "\n🧹 Cleaning up temporary files..."
rm -rf temp-configs

echo -e "\n✅ ConfigMap demo completed!"
echo "To clean up resources, run:"
echo "kubectl delete pod configmap-pod"
echo "kubectl delete configmap app-config file-config dir-config literal-config"
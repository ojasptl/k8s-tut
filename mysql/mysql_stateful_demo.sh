#!/bin/bash

# This script demonstrates how to create and manage MySQL StatefulSets in Kubernetes

# Create the MySQL namespace
echo "Creating MySQL namespace..."
kubectl create namespace mysql

# Apply the StatefulSet configuration
echo "Creating MySQL StatefulSet..."
kubectl apply -f statefulsets.yaml

# Watch the pods being created (will run until Ctrl+C is pressed)
echo "Watching pods being created one by one..."
echo "Press Ctrl+C when all pods are running to continue"
kubectl get pods -n mysql -w

# Apply the headless service
echo "Creating MySQL headless service..."
kubectl apply -f mysql-service.yaml

# Check if StatefulSet is running
echo "Checking StatefulSet status..."
kubectl get statefulset -n mysql

# List all resources
echo "Listing all MySQL resources..."
kubectl get all -n mysql

# Demonstrate connecting to specific instances
echo "To connect to a specific MySQL instance, use:"
echo "kubectl exec -it mysql-statefulset-0 -n mysql -- mysql -uroot -proot"

# Show how DNS works for StatefulSet pods
echo "Each pod gets a stable DNS name:"
echo "mysql-statefulset-0.mysql-service.mysql.svc.cluster.local:3306"
echo "mysql-statefulset-1.mysql-service.mysql.svc.cluster.local:3306"
echo "mysql-statefulset-2.mysql-service.mysql.svc.cluster.local:3306"

echo "Script completed!"
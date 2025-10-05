kubectl apply -f deployment.yaml 
# To create the deployment

# To scale the deployments to replicas of pod
kubectl scale deployment/nginx-deployment -n nginx --replicas=5

# Rollout Deployment
kubectl set image deployment/nginx-deployment -n nginx nginx=nginx:1.27.3
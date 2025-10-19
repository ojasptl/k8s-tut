cd k8s
kubectl apply -f namespace.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl port-forward service/notes-app-service -n notes-app 8000:8000 --address=0.0.0.0
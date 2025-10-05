# to create daemon sets 
kubectl apply -f daemonsets.yaml

# set the image to a new version
kubectl set image daemonset/nginx-daemonset -n nginx nginx=nginx:1.26.2
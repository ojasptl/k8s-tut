# To create a Persistent Volume
kubectl apply -f PersistentVolume.yaml
# To check for the persistent volume
kubectl get pv

# To create a Persistent Volume Claim
kubectl apply -f persistent-volume-claim.yaml

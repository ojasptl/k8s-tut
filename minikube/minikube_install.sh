curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

minikube start --driver=docker --vm=true 
# Use --vm=false if you want to run minikube without a VM i.e in not in AWS or Cloud
minikube status

minikube stop # To stop minikube
minikube delete # To delete minikube VM
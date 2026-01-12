#!/bin/bash 
set -e 

echo "Deploying app to eks"

kubectl apply -f clusterissuer.yml
kubectl apply -f deployment.yml
kubectl apply -f service.yml
kubectl apply -f ingress.yml 

echo "Deployment complete"
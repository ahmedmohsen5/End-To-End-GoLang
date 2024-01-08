#!/bin/bash

cluster_name="golang-eks-cluster"
region="us-east-1"
aws_id="465407669327"
repo_name="golange"
image_name="$aws_id.dkr.ecr.$region.amazonaws.com/$repo_name:latest"
domain="asion.great-site.net"
nameSpace="golange"

helm repo update

echo "--------------------Creating EKS--------------------"
echo "--------------------Creating ECR--------------------"
echo "--------------------Creating EBS--------------------"
echo "--------------------Deploying Ingress--------------------"
echo "--------------------Deploying Monitoring--------------------"

cd terraform && terraform init

#terraform apply -auto-approve

cd  ..

echo "--------------------Update Kubeconfig--------------------"

aws eks update-config --name $cluster_name --region $region

docker rmi -f $image_name || true

echo "--------------------Build new Image--------------------"
docker build -t $image_name ./Go_app/

echo "--------------------Login to ECR--------------------"
aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $aws_id.dkr.ecr.$region.amazonaws.com
echo "--------------------Pushing Docker Image--------------------"
docker push $image_name


echo "--------------------creating Namespace--------------------"
kubectl create namespace $nameSpace || true

echo "--------------------Deploy App--------------------"
kubectl apply -n $nameSpace -f k8s

echo "--------------------Wait for all pods to be running--------------------"
sleep 60s

echo "--------------------Ingress URL--------------------"
kubectl get ingress go-app-ingress -n $namespace -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

echo "--------------------Application URL--------------------"
echo "http://goapp.$domain"

echo "--------------------Alertmanager URL--------------------"

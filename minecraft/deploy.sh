#!/bin/bash
set -e

# ── Configuration ────
ECR_ACCOUNT_ID="839583540569"
ECR_REGION="us-east-1"
ECR_REPO="cs312-op4-ecr"
IMAGE_TAG="v1.0.1"
S3_BUCKET="cs312-op4-minecraft-world-659800275273983456"
MANIFEST_DIR="$HOME/minecraft/manifests"

echo "==> Creating ECR image pull secret..."
sudo kubectl create secret docker-registry ecr-secret \
  --docker-server=${ECR_ACCOUNT_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com \
  --docker-username=AWS \
  --docker-password=$(aws ecr get-login-password --region ${ECR_REGION}) \
  --dry-run=client -o yaml | sudo kubectl apply -f -

echo "==> Applying Kubernetes manifests..."
sudo kubectl apply -f ${MANIFEST_DIR}/minecraft-secret.yaml
sudo kubectl apply -f ${MANIFEST_DIR}/minecraft-pvc.yaml
sudo kubectl apply -f ${MANIFEST_DIR}/minecraft-deployment.yaml
sudo kubectl apply -f ${MANIFEST_DIR}/minecraft-service.yaml

echo "==> Waiting for Minecraft pod to start..."
sudo kubectl wait --for=condition=ready pod \
  -l app=minecraft \
  --timeout=300s

echo "==> Deployment complete. Current status:"
sudo kubectl get pods
sudo kubectl get service minecraft-service

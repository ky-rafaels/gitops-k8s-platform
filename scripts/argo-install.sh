#!/bin/bash

set -o errexit

# # Check if argocd command is installed
# if ! command -v argocd &> /dev/null
# then
#     echo "argocd command not found, install here: https://argo-cd.readthedocs.io/en/stable/cli_installation/#download-with-curl"
#     exit 1
# fi

# helm upgrade --install argocd ../k8s/shared-services/argo-helm \
#     --namespace argocd \
#     --create-namespace \
#     --values ../k8s/shared-services/argo-helm/custom-values.yaml

# kubectl -n argocd rollout status deploy/argocd-applicationset-controller || true
# kubectl -n argocd rollout status deploy/argocd-dex-server || true
# kubectl -n argocd rollout status deploy/argocd-notifications-controller || true
# kubectl -n argocd rollout status deploy/argocd-redis || true
# kubectl -n argocd rollout status deploy/argocd-repo-server || true
# kubectl -n argocd rollout status deploy/argocd-server || true

# may need to change this below to {.status.loadBalancer.ingress[0].hostname}
ARGOCD_ENDPOINT=$(kubectl get service argocd-server -n argocd --output=jsonpath='{.status.loadBalancer.ingress[0].hostname}')
ADMIN_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

echo "Logging into ArgoCD instance..."
argocd login $ARGOCD_ENDPOINT --username admin --password $ADMIN_PASSWORD

kubectl -n argocd patch secret argocd-secret \
-p '{"stringData": {
    "admin.password": "$2a$10$q5w/Hw0YZyF47Lid.ZcvZe9HwcN.AhogEvagjIsK21vlikfqvuN2m",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
}}'

# Cleaning up old default password
kubectl delete secret argocd-initial-admin-secret -n argocd

echo "Setting up private Git repositories.... 

---------------------------------------------
"

echo "Enter username for Gitlab CSDE"
read GIT_USER

echo "Enter password for Gitlab CSDE"
read -s GIT_PASSWORD

argocd repo add git@github.com:ky-rafaels/gitops-k8s-platform.git --username ${GIT_USER} --password ${GIT_TOKEN} --insecure-skip-server-verification

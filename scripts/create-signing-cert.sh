#!/bin/bash


# This is specific for generating a custom PKI cert and key for sealed secrets controller

set -o errexit

export PRIVATEKEY="sealed-secret.key"
export PUBLICKEY="sealed-secret.crt"
export NAMESPACE="kube-system"
export SECRETNAME="custom-encryption-key"

mkdir ./certs

# Get all active contexts 

openssl req -x509 -nodes -newkey rsa:4096 -keyout "./certs/$PRIVATEKEY" -out "./certs/$PUBLICKEY" -subj "/CN=sealed-secret/O=sealed-secret"
kubectl -n "$NAMESPACE" --context $(kubectl config current-context) create secret tls "$SECRETNAME" --cert="./certs/$PUBLICKEY" --key="./certs/$PRIVATEKEY"
kubectl -n "$NAMESPACE" --context $(kubectl config current-context) label secret "$SECRETNAME" sealedsecrets.bitnami.com/sealed-secrets-key=active

# restart sealed secrets deployment to pickup new cert for encryption
kubectl rollout restart deploy sealed-secrets -n kube-system
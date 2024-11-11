# Setting up Argocd

## ApplicationSets

Create a secret representing each cluster
```bash
k create secret generic in-cluster --from-literal=config="{'tlsClientConfig':{'insecure':false}}" --from-literal=name="in-cluster" --from-literal=server="https://kubernetes.default.svc" -n argocd
```

Label the secret 
```bash
k label secret in-cluster argocd.argoproj.io/secret-type=cluster -n argocd
```
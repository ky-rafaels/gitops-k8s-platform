
# Deploy Kind clusters with Cilium and MetalLb
```bash
cd demo-cluster-deploy
# MAC ONLY - Use script in en0 when connected to wifi. Use en7 when connected via ethernet
./en0/cilium-kind-deploy.sh 1 mgmt
./en0/cilium-kind-deploy.sh 2 cluster1 us-west us-west-1
```

# Cilium

## Cilium Network Policies
For help with building Kubernetes and Cilium networkPolicies, see editor here: https://editor.networkpolicy.io

<!-- 
# Deploy GatewayAPI CRDs
Note that gatewayAPI is not currently supported for MetalLB
https://github.com/metallb/metallb/issues/847

```bash
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml
``` -->
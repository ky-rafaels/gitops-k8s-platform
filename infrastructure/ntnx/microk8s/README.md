# Provisioning and managing the lifecycle of Microk8s edge clusters through NKP

## Clone microk8s CAPI provider
```bash
# Create a bootstrap/ temp mgmt cluster with nkp CAPI components
nkp create bootstrap

# Install microk8s CAPI bootstrap provider
git clone https://github.com/canonical/cluster-api-bootstrap-provider-microk8s.git
cd cluster-api-bootstrap-provider-microk8s
git checkout v0.6.11  # Or a known compatible tag; check releases for your CAPI version
kubectl apply -k config/default
cd ..

# Install microk8s CAPI control plane provider
git clone https://github.com/canonical/cluster-api-control-plane-provider-microk8s.git
cd cluster-api-control-plane-provider-microk8s
git checkout v0.6.11  # Match the bootstrap version
kubectl apply -k config/default

# Permissions for the microk8s service account to be able to read CRDs for preprovisioned provisioner
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: capi-microk8s-control-plane-manager-preprovmachines-rolebinding
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cappp-machines-aggregate-role
subjects:
- kind: ServiceAccount
  name: capi-microk8s-control-plane-controller-manager
  namespace: capi-microk8s-control-plane-system
EOF
```

### *NOTE: Deploy an ubuntu VM using the cloud-init script ./vm-cloud-init.yaml*

## Create an ssh key for VM
```bash
ssh-keygen # name microk8s
ssh-copy-id -i ~/.ssh/microk8s.pub ubuntu@10.38.176.95

# Test login
ssh -i ~/.ssh/microk8s ubuntu@10.38.176.95
```

## Export env vars describing ubuntu vm
```bash
export CLUSTER_NAME=microk8s-nutanix
export WORKSPACE_NAMESPACE=microk8s
export CONTROL_PLANE_0_ADDRESS=10.38.176.95
export CONTROL_PLANE_ENDPOINT_HOST=10.38.176.95
export METALLB_RANGE=10.38.176.60-10.38.176.64
export INGRESS_HOST=10.38.176.60
export SSH_USER=ubuntu
export SSH_PRIVATE_KEY_SECRET_NAME="$CLUSTER_NAME-ssh-key"
export SSH_PRIVATE_KEY_NAME=/root/.ssh/microk8s
export KUBERNETES_VERSION=v1.34.1
```

## Create secret representing private key for ubuntu vm edge cluster
```bash
kubectl create namespace microk8s
kubectl create secret generic ${SSH_PRIVATE_KEY_SECRET_NAME} -n ${WORKSPACE_NAMESPACE} --from-file=ssh-privatekey=${SSH_PRIVATE_KEY_FILE}
```

## Validate and apply microk8s CAPI manifests
```bash
clusterctl generate cluster microk8s-nutanix --from microk8s-inventory.yaml -n microk8s | kubectl apply -f -
```

## Validate cluster health and attach to mgmt cluster
```bash
nkp describe cluster -n microk8s -c microk8s-nutanix
NAME                                                                  	READY  SEVERITY  REASON  SINCE  MESSAGE
Cluster/preprov-microk8s-pro                                          	True                 	24h      	 
├─ClusterInfrastructure - PreprovisionedCluster/preprov-microk8s-pro                                        	 
└─ControlPlane - MicroK8sControlPlane/preprov-microk8s-pro-control-plane True                 	24h      	 
  └─Machine/preprov-microk8s-pro-control-plane-ll77t                  	True                 	24h
```

### Then attach cluster to MGMT cluster with kubeconfig
```bash
nkp get kubeconfig -n microk8s -c microk8s-nutanix > microk8s-kubeconfig.conf
export KUBECONFIG=$(pwd)/microk8s-kubeconfig.conf
```
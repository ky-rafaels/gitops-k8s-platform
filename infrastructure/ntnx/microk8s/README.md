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

# Create lima VM to be used for microk8s cluster
limactl create --network=lima:shared --name=ubuntu-22.04 template://ubuntu-22.04 --memory 8 --cpus 4 --disk 150
limactl start ubuntu-22.04

# Export env vars describing ubuntu vm
export CLUSTER_NAME=microk8s-nutanix
export WORKSPACE_NAMESPACE=microk8s
export CONTROL_PLANE_0_ADDRESS=192.168.105.2
export CONTROL_PLANE_ENDPOINT_HOST=192.168.105.2
export METALLB_RANGE=172.16.0.41-172.16.0.44
export INGRESS_HOST=172.16.0.41
export SSH_USER=kylerafaels
export SSH_PRIVATE_KEY_SECRET_NAME="$CLUSTER_NAME-ssh-key"
export SSH_PRIVATE_KEY_FILE=/Users/kylerafaels/.lima/_config/user
export KUBERNETES_VERSION=v1.34.1

# Create secret representing private key for ubuntu vm edge cluster
kubectl create namespace microk8s
kubectl create secret generic ${SSH_PRIVATE_KEY_SECRET_NAME} -n ${WORKSPACE_NAMESPACE} --from-file=ssh-privatekey=${SSH_PRIVATE_KEY_FILE} 

# Validate and apply microk8s CAPI manifests
envsubst < <(cat microk8s-inventory.yaml) | kubectl apply -f -
# OR
clusterctl generate cluster microk8s-nutanix --from microk8s-inventory.yaml -n microk8s | kubectl apply -f -
```
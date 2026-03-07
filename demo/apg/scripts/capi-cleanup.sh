#!/bin/bash

NAMESPACE=${1:-default}

echo "=== Deleting CAPI cluster resources in namespace: $NAMESPACE ==="

# ============================================
# STEP 1: Patch all finalizers first
# ============================================
echo ""
echo "--- Patching finalizers ---"

patch_finalizers() {
  local resource=$1
  local namespace=$2
  echo "Patching finalizers on $resource..."
  for item in $(kubectl get $resource -n $namespace -o name 2>/dev/null); do
    kubectl patch $item -n $namespace \
      -p '{"metadata":{"finalizers":[]}}' \
      --type merge 2>/dev/null && echo "  Patched: $item"
  done
}

# Patch in order - children first, parents last
patch_finalizers machinesets $NAMESPACE
patch_finalizers machines $NAMESPACE
patch_finalizers machinedeployments $NAMESPACE
patch_finalizers machinehealthchecks $NAMESPACE
patch_finalizers kubeadmconfigs $NAMESPACE
patch_finalizers kubeadmconfigtemplates $NAMESPACE
patch_finalizers kubeadmcontrolplanes $NAMESPACE
patch_finalizers kubeadmcontrolplanetemplates $NAMESPACE
patch_finalizers preprovisionedmachines $NAMESPACE
patch_finalizers preprovisionedmachinetemplates $NAMESPACE
patch_finalizers clusters $NAMESPACE

# ============================================
# STEP 2: Delete resources bottom up
# ============================================
echo ""
echo "--- Deleting resources ---"

delete_resource() {
  local resource=$1
  local namespace=$2
  count=$(kubectl get $resource -n $namespace --no-headers 2>/dev/null | wc -l)
  if [ "$count" -gt 0 ]; then
    echo "Deleting $resource..."
    kubectl delete $resource --all -n $namespace --timeout=30s 2>/dev/null \
      && echo "  Deleted: $resource" \
      || echo "  Warning: $resource deletion timed out or failed"
  else
    echo "  Skipping $resource - none found"
  fi
}

# Delete in order - children first
delete_resource machinesets $NAMESPACE
delete_resource machines $NAMESPACE
delete_resource kubeadmconfigs $NAMESPACE
delete_resource kubeadmconfigtemplates $NAMESPACE
delete_resource machinedeployments $NAMESPACE
delete_resource machinehealthchecks $NAMESPACE
delete_resource kubeadmcontrolplanes $NAMESPACE
delete_resource kubeadmcontrolplanetemplates $NAMESPACE
delete_resource preprovisionedmachines $NAMESPACE
delete_resource preprovisionedmachinetemplates $NAMESPACE
delete_resource clusters $NAMESPACE

# ============================================
# STEP 3: Clean up secrets and configmaps
# ============================================
echo ""
echo "--- Cleaning up cluster secrets ---"

for secret in $(kubectl get secrets -n $NAMESPACE \
  --no-headers -o custom-columns=":metadata.name" 2>/dev/null | \
  grep -E "\-kubeconfig$|\-ca$|\-etcd$|\-sa$|\-proxy$"); do
  echo "  Deleting secret: $secret"
  kubectl delete secret $secret -n $NAMESPACE 2>/dev/null
done

# ============================================
# STEP 4: Verify everything is gone
# ============================================
echo ""
echo "=== Verification ==="

resources=(
  clusters
  machines
  machinesets
  machinedeployments
  machinehealthchecks
  kubeadmcontrolplanes
  kubeadmcontrolplanetemplates
  kubeadmconfigs
  kubeadmconfigtemplates
  preprovisionedmachines
  preprovisionedmachinetemplates
)

all_clean=true
for resource in "${resources[@]}"; do
  count=$(kubectl get $resource -n $NAMESPACE --no-headers 2>/dev/null | wc -l)
  if [ "$count" -gt 0 ]; then
    echo "  WARNING: $resource still has $count item(s) remaining"
    kubectl get $resource -n $NAMESPACE 2>/dev/null
    all_clean=false
  else
    echo "  OK: $resource - clean"
  fi
done

echo ""
if [ "$all_clean" = true ]; then
  echo "=== All CAPI cluster resources deleted successfully ==="
else
  echo "=== Some resources may still be present - check warnings above ==="
fi

# ============================================
# STEP 5: Restart CAPI controllers to clear cache
# ============================================
echo ""
echo "--- Restarting CAPI controllers ---"
kubectl rollout restart deployment -n capi-system
kubectl rollout restart deployment -n capi-kubeadm-control-plane-system
kubectl rollout restart deployment -n capi-kubeadm-bootstrap-system
kubectl rollout restart deployment -n capi-preprovisioned-system 2>/dev/null

echo ""
echo "=== Done ==="

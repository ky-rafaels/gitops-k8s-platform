# APG Demo Deployment Steps

1. Prep workload and mgmt cluster nodes by installing rocky linux on single node 
2. Deploy mgmt cluster 
3. Install Git on mgmt cluster
4. Expose Git via traefik http,tlsRoute resource
5. Enable Harbor and mount to S3 storage
6. Push application images to Harbor
7. Create flux resources to deploy sample apps or do from project resource
8. Deploy workload cluster from mgmt


# Deployment

export SSH_PRIVATE_KEY_FILE=/Users/kylerafaels/.ssh/nkp-control


## Create preprovisioned cluster templates

```bash
nkp create cluster preprovisioned \
--cluster-name nkp-workload-1 \
--control-plane-endpoint-host 192.168.1.29 \
--control-plane-replicas 1 \
--worker-replicas 0 \
--ssh-private-key-file ${SSH_PRIVATE_KEY_FILE} \
--pre-provisioned-inventory-file worker-preprovisioned-inventory.yaml \
--dry-run -o yaml > workload-nkp-2-17.yaml
```
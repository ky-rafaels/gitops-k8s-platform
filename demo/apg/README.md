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

export NODE_IP=192.168.1.115
export VIP_INTERFACE=en08303
export CLUSTER_NAME="nkp-2-17"
export CONTROL_PLANE_VIP="192.168.1.51"
export SSH_USER=nutanix
export SSH_PRIVATE_KEY_FILE=/Users/kylerafaels/.ssh/nkp-control
export SSH_PRIVATE_KEY_SECRET_NAME="nkp-2-17-ssh-key"
export SSH_PORT=22
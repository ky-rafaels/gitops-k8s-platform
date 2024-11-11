# Script to Deploy Kind cluster in offline Deployment 
# Invoke this script to create a kind-disconnected-package.tar.gz 

# invoke image-save.sh
./image-save.sh 

# move image-save output to local directory 
cp -r ~/image-archive/belltower belltower-image-archive

mkdir helm-charts
cd helm-charts

helm repo add cilium https://helm.cilium.io/ --insecure-skip-tls-verify
helm repo update
helm pull cilium/cilium --version 1.10.4 --insecure-skip-tls-verify

cd ..
mkdir yaml-manifests
cd yaml-manifests

# Download MetalLB manifests
curl -o metallb-native.yaml https://raw.githubusercontent.com/metallb/metallb/v0.13.12/config/manifests/metallb-native.yaml

cd ..
tar -czvf kind-disconnected-package.tar.gz belltower-image-archive helm-charts yaml-manifests

rm -rf yaml-manifests helm-charts belltower-image-archive

#!/bin/bash
set -ux

# Specify needed images
# analyzers=${SAST_ANALYZERS:-"bandit eslint gosec"}
# gitlab=registry.gitlab.com/security-products/

# for i in "${analyzers[@]}"
# do
#   tarname="${i}_2.tar"
#   docker pull $gitlab$i:2
#   docker save $gitlab$i:2 -o ~/image-archive/belltower/${tarname}
#   chmod +r ~/image-archive/belltower/${tarname}
# done
timestamp=$(date -I)
# Create image directory
image_dir=~/image-archive/belltower
mkdir -p ${image_dir} 

kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec['initContainers', 'containers'][*].image}" |\
tr -s '[[:space:]]' '\n' |\
sort |\
uniq > output.txt

# delete lines matching kube components
sed -i '/metallb/d;/coredns/d;/kube-/d;/etcd/d;/kind/d' output.txt 

while IFS="" read -r i || [ -n "$i" ]
do
    echo "$i"
    tarname=$(echo ${i} | awk -F "/" '{print $NF}' | awk -F ":" '{printf $NR}').tar
    docker pull ${i}
    docker save ${i} -o ~/image-archive/belltower/${tarname}
    chmod +r ~/image-archive/belltower/${tarname}
done < output.txt

# Clean up tmp file
rm output.txt

echo "Belltower image archive created here: ${image_dir}" 
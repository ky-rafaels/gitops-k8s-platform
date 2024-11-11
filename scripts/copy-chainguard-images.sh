#!/bin/bash
### README
# DEPENDENCIES
#  - chainctl
#  - skopeo
# `brew install skopeo`
# In the future use chainctl to inspect previous image diffs and pull tag from output
# brew tap chainguard-dev/tap
# brew install chainctl

set -ux

HARBOR_REPO=equinox

kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec['initContainers', 'containers'][*].image}" |\
tr -s '[[:space:]]' '\n' |\
sort |\
grep chainguard |\
uniq > chainguard-image-list.txt

# Set all tags to latest
sed -i '' 's/:[^:]*$/:latest/g' chainguard-image-list.txt

echo 'Copy chainguard images to repo...'
while IFS="" read -r i || [ -n "$i" ]
do
    echo "$i"
    shortname=$(echo ${i} | awk -F "/" '{print $NF}' | awk -F ":" '{printf $NR}')
    tag=$(date -I)
    skopeo copy --all docker://${i} docker://${HARBOR_REPO}/${shortname}:${tag}
done < chainguard-image-list.txt

rm chainguard-image-list.txt
### Incorporate this later to check what exists in repo vs upstream
    # digest=skopeo inspect --override-os linux --override-arch amd64 docker://${i} | jq '.Digest'
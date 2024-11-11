#!/bin/bash
eksctl scale nodegroup --cluster target-cluster-1 --name ng-1-target-workers --nodes 0 --nodes-max 3 --nodes-min 0

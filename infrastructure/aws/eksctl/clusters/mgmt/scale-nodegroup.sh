#!/bin/bash
eksctl scale nodegroup --cluster cluster-deploy-test-3 --name ng-1-workers --nodes 0 --nodes-max 4 --nodes-min 0

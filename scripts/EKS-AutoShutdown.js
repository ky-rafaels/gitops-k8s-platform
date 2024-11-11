//Lambda Script to automatically shutdown EKS clusters
//Invoked via cloudwatch rule managed via cron job, likely 7pm on Friday to match our cadence 

const { EKSClient, ListClustersCommand, DescribeClusterCommand, DeleteClusterCommand } = require("@aws-sdk/client-eks");
const { AutoScalingClient, UpdateAutoScalingGroupCommand } = require("@aws-sdk/client-auto-scaling");

const eksClient = new EKSClient({ region: 'us-gov-west-1' });
const asgClient = new AutoScalingClient({ region: 'us-gov-west-1' });

exports.handler = async () => {
    try {
        const clusterNames = await listClusters();

        for (const clusterName of clusterNames) {
            const { tags, resourcesVpcConfig } = await describeCluster(clusterName);

            if (tags.Persistent === "true") {
                console.log(`Scaling down EKS cluster: ${clusterName}`);
                await scaleDownCluster(resourcesVpcConfig.nodeGroup);
            } else {
                console.log(`Terminating EKS cluster: ${clusterName}`);
                await eksClient.send(new DeleteClusterCommand({ name: clusterName }));
            }
        }
    } catch (error) {
        console.error('Error processing EKS clusters:', error);
    }
};

async function listClusters() {
    const response = await eksClient.send(new ListClustersCommand({}));
    return response.clusters;
}

async function describeCluster(clusterName) {
    const response = await eksClient.send(new DescribeClusterCommand({ name: clusterName }));
    return {
        tags: response.cluster.tags,
        resourcesVpcConfig: response.cluster.resourcesVpcConfig
    };
}

async function scaleDownCluster(nodeGroupName) {
    await asgClient.send(new UpdateAutoScalingGroupCommand({
        AutoScalingGroupName: nodeGroupName,
        DesiredCapacity: 0
    }));
}

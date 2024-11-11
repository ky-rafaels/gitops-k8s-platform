//Lambda Script to automatically shutdown hosts in region
//Invoked via cloudwatch rule managed via cron job, likely 7pm 

const { EC2Client, DescribeInstancesCommand, StopInstancesCommand } = require("@aws-sdk/client-ec2");
const ec2Client = new EC2Client({ region: 'us-gov-west-1' });

exports.handler = async (event) => {
    try {
        const instances = await getInstances('running');
        if (instances.length > 0) {
            const stopInstancesResult = await ec2Client.send(new StopInstancesCommand({ InstanceIds: instances }));
            console.log('Stopped instances:', instances);
        } else {
            console.log('No running instances found to stop.');
        }
    } catch (error) {
        console.error('Error stopping instances:', error);
    }
};

const getInstances = async (state) => {
    const params = {
        Filters: [
            {
                Name: 'instance-state-name',
                Values: [state]
            }
        ]
    };

    const response = await ec2Client.send(new DescribeInstancesCommand(params));
    const instances = [];
    response.Reservations.forEach(reservation => {
        reservation.Instances.forEach(instance => {
            instances.push(instance.InstanceId);
        });
    });

    return instances;
};

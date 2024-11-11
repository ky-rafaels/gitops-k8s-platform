const https = require('https');
const zlib = require('zlib');

const SPLUNK_HEC_URL = "http://<network ip>.com:8088/services/collector";
const SPLUNK_HEC_TOKEN = ""; //add token

exports.handler = (event, context, callback) => {
    const payloads = [];

    // Process each CloudWatch log event
    event.records.forEach((record) => {
        // Decode base64 and decompress the log data
        const compressedData = Buffer.from(record.kinesis.data, 'base64');
        const decompressedData = zlib.gunzipSync(compressedData);
        const logEvents = JSON.parse(decompressedData.toString('utf8')).logEvents;

        // Prepare each log event to be sent to Splunk
        logEvents.forEach((logEvent) => {
            const payload = {
                sourcetype: "_json",
                event: logEvent.message,
            };
            payloads.push(payload);
        });
    });

    // Send the payloads to Splunk
    const sendToSplunk = (payload) => {
        const data = JSON.stringify(payload);
        const options = {
            hostname: '<your-splunk-ec2-public-ip>',
            port: 8088,
            path: '/services/collector',
            method: 'POST',
            headers: {
                'Authorization': `Splunk ${SPLUNK_HEC_TOKEN}`,
                'Content-Type': 'application/json',
                'Content-Length': data.length
            }
        };

        const req = https.request(options, (res) => {
            console.log(`Splunk HEC responded with status code: ${res.statusCode}`);
            res.on('data', (d) => {
                process.stdout.write(d);
            });
        });

        req.on('error', (e) => {
            console.error(`Error sending data to Splunk: ${e.message}`);
        });

        req.write(data);
        req.end();
    };

    // Send each payload to Splunk
    payloads.forEach((payload) => sendToSplunk(payload));

    // Indicate successful processing
    callback(null, `Successfully processed ${event.records.length} records.`);
};

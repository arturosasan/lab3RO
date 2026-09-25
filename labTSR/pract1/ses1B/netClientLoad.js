const net = require("net");
const args = process.argv.slice(2);
const SERVER_IP = args[0];
const LOCAL_IP = args[1];

if (process.argv.length < '3') {
    console.log('ERROR: Use "$ node netServerLoad.js <SERVER_IP> <LOCAL_IP>"')
    process.exit();
}

const client = net.connect({ port: 8000, host: SERVER_IP }, function () {
        console.log("client connected");
        client.write(JSON.stringify({ ip: LOCAL_IP }));
    });

    
    client.on("data", function (data) {
        const resp = JSON.parse(data.toString());
        console.log("server = " + resp.ip + " load = " + resp.load);
        client.end(); 
    });

    client.on("end", function () {
        console.log("client disconnected, bye!");
    });
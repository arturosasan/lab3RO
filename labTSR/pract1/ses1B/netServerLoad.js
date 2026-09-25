const net = require('net');
const fs = require('fs');

function getLoad() {
    var loadavg = fs.readFileSync("/proc/loadavg").toString().split(' ');
    const min1 = parseFloat(loadavg[0]) + 0.01;
    const min5 = parseFloat(loadavg[1]) + 0.01;
    const min15 = parseFloat(loadavg[2]) + 0.01;
    return min1 * 10 + min5 * 2 + min15;
}

const server = net.createServer(function (c) {
    console.log('server: client connected');
    c.on('end', function () {
        console.log('server: client disconnected');
    });

    c.on('data', function (data) {
        const req = JSON.parse(data.toString());
        console.log('request from ' + req.ip);
        c.write(JSON.stringify({ ip: '127.0.0.1', load: getLoad() })); // locally
        c.end();
    });
});

server.listen(8000, function() {
    console.log('server bound, listening on port 8000');
});
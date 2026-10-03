const net = require('net');

// Puerto donde entran los clientes (8000) y donde llegan las nuevas instrucciones (8001)
const LOCAL_PORT = 8000;
const CONFIG_PORT = 8001;
const LOCAL_IP = '127.0.0.1';

// El destino actual. Se cambia en caliente cuando entra una instrucción por el puerto 8001
let REMOTE_IP = process.argv[2];
let REMOTE_PORT = parseInt(process.argv[3]);

// Se comprueba que le HAS dado los argumentos al final
if (!REMOTE_IP || isNaN(REMOTE_PORT)) {
	console.log('Use: $ node ProxyProgramable.js <REMOTE_IP> <REMOTE_PORT>');
	process.exit(1);
}


const server = net.createServer(function (socket) {
	// El socket al servidor remoto tiene que crearse AQUÍ DENTRO, no fuera.
	// Si estuviera fuera, todos los clientes usarían el mismo socket y sus datos se mezclarían.
	const serviceTOSocket = net.connect(REMOTE_PORT, REMOTE_IP);

	// Lo que llega del cliente, se pasa tal cual al remoto
	socket.on('data', function (data) {
		serviceTOSocket.write(data);
	});

	// Lo que llega del remoto, se pasa tal cual al cliente
	serviceTOSocket.on('data', function (data) {
		socket.write(data);
	});

	// Si el remoto no existe, sin esto Node se queixa y PARA TODO el proxy
	serviceTOSocket.on('error', function (err) {
		console.log('error trying to connect with remote destiny: ' + err.message);
		socket.destroy(); // el cliente se cierra porque no hay a quién contestarle
	});

	socket.on('error', function () {}); // si el cliente se cae y avisa, no se detiene el proceso
});

server.listen(LOCAL_PORT, LOCAL_IP);
console.log(`proxy listening in ${LOCAL_PORT}, destiny => ${REMOTE_IP}:${REMOTE_PORT}`);


const configServer = net.createServer(function (controlSocket) {
	controlSocket.on('data', function (data) {
		// El mensaje que nos manda programador.js
		const msg = JSON.parse(data.toString());

		// Solo cambiamos las dos variables. Las conexiones que ya están abiertas
		// NO se tocan: siguen hablando con su servidor. Solo las nuevas usan el destino nuevo.
		REMOTE_IP = msg.remote_ip;
		REMOTE_PORT = parseInt(msg.remote_port);

		console.log("traffic redirected to " + REMOTE_IP + ':' + REMOTE_PORT);
	});

	controlSocket.on('error', function () {}); // por si se corta la instrucción a medias
});

configServer.listen(CONFIG_PORT, LOCAL_IP);
console.log("waiting for changes at port ->",  CONFIG_PORT);
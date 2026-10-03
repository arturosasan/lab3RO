const net = require('net');

// Puerto donde escucha el proxy para recibir cambios de destino
const CONFIG_PORT = 8001;

// Se leen los argumentos: dónde está el proxy, y el destino nuevo
const IP_PROXY = process.argv[2];
const NEW_IP = process.argv[3];
const NEW_PORT = parseInt(process.argv[4]);

// Se comprueba que están todos antes de intentar nada
if (!IP_PROXY || !NEW_IP || isNaN(NEW_PORT)) {
	console.log('use: $ node programador.js <IP_PROXY> <NUEVA_IP> <NUEVO_PUERTO>');
	process.exit(1);
}

// El mensaje que le mandamos al proxy
const msg = JSON.stringify({
	remote_ip: NEW_IP,
	remote_port: NEW_PORT
});

const client = new net.Socket();

// Nos conectamos al puerto de configuración del proxy y le mandamos el mensaje
client.connect(CONFIG_PORT, IP_PROXY, function () {
	client.write(msg); // le envío el destino nuevo
	client.end(); // ya no tengo nada más que enviar
	console.log('config send:', msg);
});

// Sin esto, si el proxy no está arrancado, salta una pantalla de errores
client.on('error', function (err) {
	console.log('proxy unavailable: ' + err.message);
});
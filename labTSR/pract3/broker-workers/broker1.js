const {zmq,lineaOrdenes,traza,error,adios,creaPuntoConexion} = require("../tsr")
lineaOrdenes("frontendPort interPort")
let libres = 0 // cuantos workers libres tiene broker2
let pendiente = [] // peticiones no enviadas a broker2
let frontend = zmq.socket("router") // clientes
let inter = zmq.socket("dealer") // broker2

creaPuntoConexion(frontend, frontendPort)
creaPuntoConexion(inter, interPort)

function procesaPeticion(cliente, sep, msg) {
    // llega peticion desde cliente
    traza("procesaPeticion", "cliente sep msg", [cliente, sep, msg])
    if (libres > 0) {
        libres--
        inter.send([cliente, msg])
    } else pendiente.push([cliente, msg])
}

function procesaMsgBroker2(cliente, resp) {
    // todo mensaje de broker2 significa "un worker ha quedado libre"
    traza("procesaMsgBroker2", "cliente resp", [cliente, resp])
    libres++
    if (cliente + "") frontend.send([cliente, "", resp]) // trae una respuesta (si no, era un alta)
    if (pendiente.length) {
        // hay trabajos pendientes. Le pasamos el mas antiguo a broker2
        libres--
        inter.send(pendiente.shift())
    }
}

frontend.on("message", procesaPeticion)
frontend.on("error", (msg) => {error(`${msg}`);})
inter.on("message", procesaMsgBroker2)
inter.on("error", (msg) => {error(`${msg}`);})
process.on("SIGINT", adios([frontend, inter], "abortado con CTRL-C"))
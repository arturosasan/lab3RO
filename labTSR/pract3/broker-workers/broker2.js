const { zmq, lineaOrdenes, traza, error, adios, creaPuntoConexion, conecta } = require("../tsr")
lineaOrdenes("backendPort broker1Host broker1Port")
let total = 0
let workers = [] // workers disponibles
let atendidas = {} // peticiones atendidas por cada worker
let backend = zmq.socket("router") // workers
let inter = zmq.socket("dealer") // broker1

creaPuntoConexion(backend, backendPort)
conecta(inter, broker1Host, broker1Port)

function procesaPeticion(cliente, msg) {
    // llega peticion desde broker1, que solo envia si hay algun worker libre
    traza("procesaPeticion", "cliente msg", [cliente, msg])
    backend.send([workers.shift(), "", cliente, msg])
}

function procesaMsgWorker(worker, sep, cliente, resp) {
    traza("procesaMsgWorker", "worker sep cliente resp", [worker,sep,cliente,resp])
    workers.push(worker) // alta o respuesta: el worker queda disponible
    if (cliente + "") {
        total += 1
        atendidas[worker] = (atendidas[worker] || 0) + 1
    }
        inter.send([cliente, resp]) // avisa a broker1: un worker libre (y la respuesta, si la hay)
    }
inter.on("message", procesaPeticion)
inter.on("error", (msg) => {error(`${msg}`)})

backend.on("message", procesaMsgWorker)
backend.on("error", (msg) => {error(`${msg}`)})

process.on("SIGINT", adios([backend, inter], "abortado con CTRL-C"))
setInterval(() => {console.log(`Total atendidas: ${total}`, atendidas)}, 5000)
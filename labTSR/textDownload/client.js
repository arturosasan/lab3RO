const {zmq, fs, error, adios, traza, conecta} = require('./tsr')

const ipServidor = process.argv[2]
const portServidor = process.argv[3]
const fileName = process.argv[4]

if (!ipServidor || !portServidor || !fileName) {
    console.error('Use: node cliente.js <ip> <port> <fileName>')
    process.exit(1)
}

let req = zmq.socket('req')

conecta(req, ipServidor, portServidor)

req.send(fileName) // unicamente se le manda al servidor el nombre del fichero a descargar

const INFO_M = '[INFO]: '
const SERVER_M = '[SERVER]: '

function processingAnswer() {
    // cada cacho es 1k de datos enviado por el servidor
    const cachos = Array.prototype.slice.call(arguments)

    traza('processingAnswer', 'numcachos', [cachos.length])

    const answer = Buffer.concat(cachos) // concatenamos toda la respuesta que nos devuelve el servidor en un único cacho

    if (cachos.length === 1 && answer.toString().startsWith('ERROR')) { // servidor programado para mandar un único cacho que diga ERROR si el fichero no existe
        error(SERVER_M + answer.toString())
        adios([req], INFO_M + ' download failed')()
        return
    }

    fs.writeFile(fileName, answer, (err) => {
        if (err) {
            error(SERVER_M + 'error saving the file: ' + err)
            adios([req], INFO_M + 'error saving the file')()
            return
        }
        console.log(INFO_M + fileName +  ' saved'+ ' (' + answer.length + ' bytes)')
        adios([req], INFO_M + 'finished')()
    })

    //fs.close()
}

req.on('message', processingAnswer)
req.on('error', (msg) => { error(`${msg}`) })
process.on('SIGINT', adios([req], 'server aborted with CTRL-C'))
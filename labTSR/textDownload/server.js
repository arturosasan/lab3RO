const {zmq, path, fs, error, adios} = require('./tsr')


const portServidor = process.argv[2]

let rep = zmq.socket('rep')

rep.bind(`tcp://*:${portServidor}`, (err) => {
    if (err) {
        error('something went wrong pairing: ' + err)
        return
    }
    console.log('server listening on port ' + portServidor)
})

const TAM_BLOQUE = 1024

function handlingRequest() {
    const fileName = Buffer.concat(Array.prototype.slice.call(arguments)).toString().trim()
    const filePath = path.join(__dirname, 'textos', fileName)

    console.log('petition arrived to download file ->', fileName)

    fs.readFile(filePath, (err, data) => {
        if (err) {
            // un solo frame de texto && empieza por error = el cliente sabe que algo ha ido mal  
            rep.send('ERROR: FILE NOT FOUND')
            return
        }

        // se parte el el contenido en cachos de 1K
        const cachos = []
        for (let i = 0; i < data.length; i += TAM_BLOQUE) {
            cachos.push(data.subarray(i, i + TAM_BLOQUE))
        }
        if (cachos.length === 0) cachos.push(Buffer.alloc(0)) // si no hay nada al acabar el for donde metemos los cachos a enviar -> fichero vacío

        rep.send(cachos) // se envia todo de una, en cachos de 1k 
    })

    fs.close()
}

rep.on('message', handlingRequest)
rep.on('error', (msg) => { error(`${msg}` ) })
process.on('SIGINT', adios([rep], 'server aborted with CTRL-C'))
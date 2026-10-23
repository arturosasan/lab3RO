const {zmq, error, adios, creaPuntoConexion, traza} = require('../tsr')

const port = parseInt(process.argv[2])
const numM = parseInt(process.argv[3])
const temas = process.argv.slice(4)

if (temas.length == 0) {
    error('you must submit at least a theme')
    process.exit(1)
}
let pub = zmq.socket('pub')
//creaPuntoConexion(pub, port)
console.log('pub socket created on port' , port)


/*
function envia(tema, numMensaje, ronda) {
traza('envia','tema numMensaje ronda',[tema, numMensaje, ronda])
pub.send([tema, numMensaje, ronda])
}
*/

function messageSend(indexM) {
    const temaIndex = indexM % temas.length // current msg
    const tema = temas[temaIndex]
    const ronda = Math.trunc (indexM/ temas.length) + 1

    //envia(temas[indexM%3], indexM, Math.trunc(indexM/3))
    console.log(tema, indexM + 1, ronda)

    if (indexM + 1 >= numM) {
        adios([pub], 'socket publisher finished')()
    } else {
        setTimeout(() => messageSend(indexM + 1), 1000)
    }
}

messageSend(0)
pub.on('error', (msg) => {error(`${msg}`)})
process.on('SIGINT', adios([pub],"abortado con CTRL-C"))
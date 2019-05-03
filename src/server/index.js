import express from 'express'
import cors from 'cors'
import fs from 'fs'
import bodyParser from 'body-parser'

const PORT = process.env.PORT || 3000
const server = express()
server.use(bodyParser.json())
server.use(cors())

const configPath = `${__dirname}/config/config.json`
const schemaPath = `${__dirname}/config/schema.json`
const uiSchemaPath = `${__dirname}/config/ui-schema.json`
const indexPath = `${__dirname}/index.html`


function asyncFlow(generatorFunction) {
  function callback(err) {
    if(err) {
      return generator.throw(err)
    }
    const results = [].slice.call(arguments, 1)
    generator.next(results.length> 1 ? results : results[0])
  }
    const generator = generatorFunction(callback)
    generator.next()
}

function getFile (path, res) {
  return asyncFlow(function* (callback) {
    const file = yield fs.readFile(path, 'utf8', callback)
    res.format({'application/json': () => res.send(file)}) // json already. No need to stringify it in the response
  })
}

function writeFile (path, data, res) {
  return asyncFlow(function* (callback) {
    try {
      yield fs.writeFile(path, JSON.stringify(data, null, 2), callback)
      res.json({})
    }
    catch (error) {
      res.status(500).json({error})
    }
  })
}

// ROUTES

// API Routes
server.get('/api/config', (req, res) => getFile (configPath, res))
server.get('/api/schema', (req, res) => getFile (schemaPath, res))
server.get('/api/ui-schema', (req, res) => getFile (uiSchemaPath, res))

server.put('/api/config', (req, res) => writeFile (configPath, req.body, res))

function serveStatic (paths) {
  paths.map(path => {
    server.use(path, express.static('dist'))
    server.get(path, (req, res) => {
      res.sendFile(indexPath)
    })
  })
}
if (process.env.NODE_ENV === 'production') {
  serveStatic(['/', '/settings'])
}

server.listen(PORT, function () {
  console.log('Server listening on', PORT)
})

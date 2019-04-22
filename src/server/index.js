import express from 'express'
import cors from 'cors'
import fs from 'fs'

const PORT = process.env.PORT || 3000
const server = express()
server.use(cors())

const dataPath = `${__dirname}/../config/data.json`
const schemaPath = `${__dirname}/../config/schema.json`


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
    res.set('Content-Type', 'appication/json');
    res.send(file)
  })
}

// Routes
server.get('/api/config', (req, res) => getFile (dataPath, res))
server.get('/api/schema', (req, res) => getFile (schemaPath, res))

server.listen(PORT, function () {
  console.log('Server listening on', PORT)
})

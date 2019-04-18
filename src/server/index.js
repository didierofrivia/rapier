import express from 'express'

const PORT = process.env.PORT || 3000
const server = express()

/*
set up all your server config here
*/

server.listen(PORT, function () {
  console.log('Server listening on', PORT)
})

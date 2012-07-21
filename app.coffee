app = (express = require 'express').createServer()
  .use(express.static "#{__dirname}/public")
  .use(do (require 'connect-assets'))
app.set 'view engine', 'ejs'
app.get '/', (_, res) -> res.render 'index'
app.listen 3000

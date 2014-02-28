util = require 'util'
_    = require 'underscore'
k    = require './common'

parse = (ast) ->
  ast

if not module.parent?
  fs   = require('fs')
  filename = process.argv[2]

  if not filename?
    k.log("You must provide a file to be parsed")
  else
    k.log("Reading file '#{filename}'")
    fs.readFile(filename, encoding:'utf8', (err, raw) ->
      lexed = JSON.parse(raw)

    )

_     = require('underscore')
async = require('async')
k     = require('./common')
c     = require('./constants')

parse = (data) ->

if not module.parent?
  fs = require('fs')
  filename = process.argv[2]

  if not filename?
    _.log("You must provide a lexed file to be parsed")
  else
    _.log("Reading file '#{filename}'")
    fs.readFile(filename, encoding:'utf8', (err, raw) ->
      lex = JSON.parse(raw)
      parsed = parse(lex)
      #fs.writeFile("#{filename}.parsed", JSON.stringify(ast), encoding:'utf8', (err) ->
        #_.log("Done"))
    )


util = require 'util'
_    = require 'underscore'
k    = require './common'

LIST = "list"
ACALL = "call"
AINIT = "init"

parse = (ast, scope = []) ->
  console.log("Parsing")
  scope = _(scope).clone()
  islst = (token) -> token.type == LIST
  sym   = (token) -> _(token.value).first()
  args  = (token) -> _(token.value).rest()

  ptok  = (token) ->
    symbol = sym(token)

    if not _(scope).contains(symbol.token)
      symbol.action = AINIT
      scope.push(symbol)
    else
      symbol.action = CALL

    body = args(token)
    result = _(body)
      .map((subtoken) ->
        if subtoken.type == LIST
          parse(subtoken, scope)
        else
          subtoken)
    result.unshift(symbol)
    result

  if _(ast).isArray()
    _(ast).map(ptok)
  else
    ptok(ast)

if not module.parent?
  fs   = require('fs')
  filename = process.argv[2]

  if not filename?
    k.log("You must provide a file to be parsed")
  else
    k.log("Reading file '#{filename}'")
    fs.readFile(filename, encoding:'utf8', (err, raw) ->
      lexed = JSON.parse(raw)
      k.inspect(parse(lexed)))

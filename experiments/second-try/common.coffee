util = require('util')
_    = require 'underscore'

exports.set = (obj, fn) -> fn( _(obj).clone())
exports.assertnull = (obj, msg, fn) ->
  if obj == null then throw msg
  obj

exports.out = (str) -> process.stdout.write(str)
exports.log = (data) -> console.error(data)
exports.inspect = (data) ->
  console.error(util.inspect(data, {colors:true,depth:null}))
exports.islst = (lst) -> _(lst).has('car')
exports.plist = (lst) ->
  while lst?
    if lst.car? and islst(lst.car)
      out("(")
      plist(lst.car)
      out(")")
    else
      if lst.car?
        out(String(lst.car.token))
    lst = lst.cdr

exports.past = (lst, indent) ->
  indent ?= 0
  while lst?
    if lst.car? and islst(lst.car)
      past(lst.car, indent + 1)
    else
      if lst.car?
        for i in [0...indent]
          out(" ")
        if lst.car.type == 'identifier'
          console.log("identifier [#{lst.car.token}]")
        else
          console.log(String(lst.car.type))
    lst = lst.cdr

exports.putlex = (lexeme) ->
  if lexeme?
    process.stderr.write String(lexeme.token)
  else
    process.stderr.write "[NULL]"
  lexeme


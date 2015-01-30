_      = require('lodash')

primitives = require("./primitives")
rules = require("./rules")

functions =
  add : (args...) ->
    _.reduce(args..., (acc, arg) ->
      acc + arg
    , 0)

  sub : (args...) ->
    _.reduce(_.rest(args...), (acc, arg) ->
      acc - arg
    , _.first(args...))
  div : (args...) ->
    _.reduce(_.rest(args...), (acc, arg) ->
      acc / arg
    , _.first(args...))
  mul : (args...) ->
    _.reduce(_.rest(args...), (acc, arg) ->
      acc * arg
    , _.first(args...))

functionNames = _(functions).keys()

list = (form) ->
  items = _(form.des)
  call = evaluate(items.first())
  if not functionNames.contains(call)
    console.log "TODO: HANDLE THIS ERROR"
  else
    args = items.rest().map((item) -> evaluate(item)).value()
    functions[call](args)

symbol = (form) ->
  intTest = /\d+/
  floatTest = /\d+\.\d+/

  if intTest.test(form.ch)
    parseInt(form.ch)
  else if floatTest.test(form.ch)
    parseFloat(form.ch)
  else
    form.ch


evaluate = (form) ->
  if form.t == "de"
    if rules.types[form.ch] == "list"
      list(form)
  else if form.t == 'sy'
    symbol(form)

module.exports = evaluate

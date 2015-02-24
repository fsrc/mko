_       = require('lodash')
reader  = require('./reader')
errors  = require('./errors')
macro_evaluator = require('./macro-evaluator')
macros = require("./macros")
symbols = require("./symbols")

printCode = (form) ->
  children = _.map(form.children, (f) -> printCode(f)).join(' ') if form.children?
  if children?
    form.str + children + ")\n"
  else
    form.str


module.exports = (stream) ->
  do (stream) ->
    scope =
      mac         : macros
      symbols     : symbols
      evaluator   : macro_evaluator
      last_result : null

    reader(stream)
      .onAtom((form) ->
        scope = macro_evaluator(scope, form))

      .onError((code, args...) ->
        console.log("Reader error:", errors(code, args...))
        process.exit(code))

      .onEnd(() ->
        console.log("Result", scope)
        console.log("Done"))


_       = require('lodash')
reader  = require('./reader')
maceval = require('./macro-evaluator')
errors  = require('./errors')
block_evaluator = require("./macro-evaluator/forms/form-in-block")

printCode = (form) ->
  children = _.map(form.children, (f) -> printCode(f)).join(' ') if form.children?
  if children?
    form.str + children + ")\n"
  else
    form.str


module.exports = (stream) ->
  do (stream) ->
    scope =
      mac:{}
      fun:{}
      var:{}

    last_result = null
    macros = require('./macro-evaluator/built-in')
    defines = require('./macro-evaluator/defines')
    expression_evaluator = block_evaluator(maceval, macros, scope)
    reader(stream)
      .onAtom((form) ->
        last_result = expression_evaluator(last_result, form))

      .onError((code, args...) ->
        console.log("Reader error:", errors(code, args...))
        process.exit(code))

      .onEnd(() ->
        console.log("Result", last_result)
        console.log("Done"))


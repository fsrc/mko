_       = require('lodash')
reader  = require('./reader')
maceval = require('./macro-evaluator')
errors  = require('./errors')

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
    reader(stream)
      .onAtom((form) ->
        expanded = maceval(form, scope)
        if expanded.form == 'macro'
          scope.mac[form.name] = expanded

        if expanded?
          console.log "Form post macro expansion"
          console.log printCode(expanded))

      .onError((code, args...) ->
        console.log("Reader error:", errors(code, args...))
        process.exit(code))
      .onEnd(() -> console.log("Done"))


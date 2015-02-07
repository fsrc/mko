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
  reader(stream)
    .onAtom((form) ->
      #console.log "Form pre macro expansion"
      #console.log printCode(form)
      console.log "Form post macro expansion"
      console.log printCode(maceval(form)))
    .onError((code, args...) ->
      console.log("Reader error:", errors(code, args...))
      process.exit(code))
    .onEnd(() -> console.log("Done"))


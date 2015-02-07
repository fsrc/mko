_      = require('lodash')
reader = require('./reader')
errors = require('./errors')

printCode = (form) ->
  children = _.map(form.children, (f) -> printCode(f)).join(' ') if form.children?
  if children?
    form.str + children + "\n"
  else
    form.str

module.exports = (stream) ->
  reader(stream)
    .onAtom((form) ->
      console.log "Form"
      console.log printCode(form))
      #console.log JSON.stringify(form, null, 2))
      #console.log("Evaluated:", form.eval(form)))
    .onError((code, args...) ->
      console.log("Reader error:", errors(code, args...))
      process.exit(code))
    .onEnd(() -> console.log("Done"))


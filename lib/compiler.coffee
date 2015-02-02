_      = require('lodash')
reader = require('./reader')
errors = require('./errors')


module.exports = (stream) ->
  reader(stream)
    .onAtom((form) ->
      console.log("Evaluated:", form.eval(form)))
    .onError((code, args...) ->
      console.log("Reader error:", errors(code, args...))
      process.exit(code))
    .onEnd(() -> console.log("Done"))


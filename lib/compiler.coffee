_      = require('lodash')
reader = require('./reader')
evaluate = require('./evaluator')
errors = require('./errors')

rules =
  delimiters  : _(['(',')','[',']','{','}',"<",">"])
  space       : _([' ','\t'])
  linefeed    : _(['\n'])
  starters    : _(['(','[','{',"<"])
  enders      : _([')',']','}',">"])
  quotes      : _(['"', "'"])
  esc         : _(['\\'])
  comment     : _([';'])
  pairs :
    "(" : ")"
    "[" : "]"
    "{" : "}"
    "<" : ">"
    "'" : "'"
    ";" : "\n"
    '"' : '"'

module.exports = (stream) ->
  reader(stream)
    .onAtom((form) -> console.log("Evaluated:\n", evaluate(form)))
    .onError((code, args...) ->
      console.log("reader error:", errors(code, args...))
      process.exit(code))
    .onEnd(() -> console.log("Done"))


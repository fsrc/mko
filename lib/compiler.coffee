_      = require('lodash')
reader = require('./reader')

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
    .onAtom((atom) -> console.log(atom))
    .onError((error) -> console.log(error))
    .onEnd(() -> console.log("Done"))

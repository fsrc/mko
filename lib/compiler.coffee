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
  _.compose(
    _.partial(reader.symbol, rules)
    _.partial(reader.delimiter, rules)
    _.partial(reader.space, rules)
    _.partial(reader.comment, rules)
    _.partial(reader.string, rules)
    _.partial(reader.char, rules)
    )(stream)

    .onAtom((atom) -> console.log(atom))
    .onError((error) -> console.log(error))
    .onEnd(() -> console.log("Done"))

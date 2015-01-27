_ = require("lodash")

char      = require("./class/char")
string    = require("./class/string")
comment   = require("./class/comment")
space     = require("./class/space")
delimiter = require("./class/delimiter")
symbol    = require("./class/symbol")
strip     = require("./class/strip")
nest      = require("./class/nest")

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

module.exports = _.compose(
  _.partial(nest, rules)
  _.partial(strip, rules)
  _.partial(symbol, rules)
  _.partial(delimiter, rules)
  _.partial(space, rules)
  _.partial(comment, rules)
  _.partial(string, rules)
  _.partial(char, rules))

_ = require("lodash")

module.exports =
  delimiters  : _ ['(',')','[',']','{','}',"<",">"]
  space       : _ [' ','\t']
  linefeed    : _ ['\n']
  eof         : _ ['\0']
  starters    : _ ['(','[','{',"<"]
  enders      : _ [')',']','}',">"]
  quotes      : _ ['"', "'"]
  esc         : _ ['\\']
  comment     : _ [';']
  pairs :
    "(" : ")"
    "[" : "]"
    "{" : "}"
    "<" : ">"
    "'" : "'"
    ";" : "\n"
    '"' : '"'

  types :
    "(" : "list"
    "[" : "array"
    "{" : "object"
    "<" : "tuple"

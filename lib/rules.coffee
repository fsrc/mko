_ = require("lodash")

module.exports =
  #delimiters  : _ ['(',')']
  #space       : _ [' ','\t']
  #linefeed    : _ ['\n']
  #eof         : _ ['\0']
  #string      : _ ['"']
  #esc         : _ ['\\']
  #comment     : _ [';']

  classes :
    linefeed    : /^\n$/      # \n
    delimiter   : /^[\(\)]$/  # ()
    space       : /^[\s\t]+$/ # \s\t
    eof         : /^\0$/      # \0
    string      : /^"([^"]*)"$/       # "
    esc         : /^\\\w$/    # \?
    comment     : /^;;[^\n]*$/ # ;;

  pairs :
    "(" : ")"

  types :
    "(" : "list"


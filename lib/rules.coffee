_ = require("lodash")

module.exports =
  classes :
    linefeed    : /^\n$/      # \n
    delimiter   : /^[\(\)]$/  # ()
    space       : /^[\s\t]+$/ # \s\t
    eof         : /^\0$/      # \0
    string      : /^"$/  # "
    esc         : /^\\\w$/    # \?
    comment     : /^;$/ # ;;

  pairs :
    "(" : ")"

  types :
    "(" : "list"

  forms :
    list   : /^[\(\)]$/  # ()
    number : /^\d+\.\d+$/
    int    : /^\d+$/
    string : /^"/


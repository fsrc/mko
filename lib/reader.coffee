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
  delimiters  : _ ['(',')','[',']','{','}',"<",">"]
  space       : _ [' ','\t']
  linefeed    : _ ['\n']
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

primitives = _ [

  "def"    # Generic
  "int"    # Integer
  "str"    # String
  "char"   # Character
  "date"   # Date
  "num"    # Float
  "bool"   # Boolean

  "list"   # Linked list of items
  "array"  # Array of items
  "object" # Hashmap
  "tuple"  # Tuple

  "quote"  # For quoting lists that should not be evaluated
  "fun"    # Function
  "mac"    # Macro

  "either" # Execute either fun A or B

  "and"    # Boolean and
  "or"     # Boolean or
  "not"    # Boolean not
  "xor"    # Boolean xor

  "rec"    # Recursion of anonymous func
  "use"    # Reference another module

  "add"    # Addition
  "sub"    # Subtraction
  "div"    # Division
  "mul"    # Multiplication

  "stdout" # Standard output
  "errout" # Error output
  "stdin"  # Standard input

]

module.exports = _.compose(
  _.partial(nest, rules)
  _.partial(strip, rules)
  _.partial(symbol, rules)
  _.partial(delimiter, rules)
  _.partial(space, rules)
  _.partial(comment, rules)
  _.partial(string, rules)
  _.partial(char, rules))


_ = require("lodash")
fs = require("fs")
path = require("path")

#"def"    # Generic
#"int"    # Integer
#"str"    # String
#"char"   # Character
#"date"   # Date
#"num"    # Float
#"bool"   # Boolean

#"list"   # Linked list of items
#"array"  # Array of items
#"object" # Hashmap
#"tuple"  # Tuple

#"quote"  # For quoting lists that should not be evaluated
#"fun"    # Function
#"mac"    # Macro

#"either" # Execute either fun A or B

#"and"    # Boolean and
#"or"     # Boolean or
#"not"    # Boolean not
#"xor"    # Boolean xor

#"rec"    # Recursion of anonymous func
#"use"    # Reference another module

#"add"    # Addition
#"sub"    # Subtraction
#"div"    # Division
#"mul"    # Multiplication

#"stdout" # Standard output
#"errout" # Error output
#"stdin"  # Standard input

currentdir = path.dirname(module.id)

module.exports = (rules) ->
  _(fs.readdirSync(currentdir))
    .map((f) -> path.basename(f, ".coffee"))
    .remove((f) -> f != "index")
    .map((p) -> _.partial(require("./#{p}"), rules))
    .value()

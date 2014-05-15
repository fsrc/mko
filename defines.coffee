_     = require("underscore")
chalk = require("chalk")

starters    = ['[','(','{','<']
enderof     = {'[':']','(':')','{':'}','<':'>'}
enders      = [']',')','}','>']
starts      = starters.join('\\')
ends        = enders.join('\\')
predelimit  = "\\#{starts}\\s:^"
postdelimit = "\\#{ends}\\s:;$"
delimiters  = "/"
exports.patterns =
  string :
    color      : chalk.yellow
    rex        : "\".+\""
    precedents : ['note', 'regex']

  regex :
    color      : chalk.red
    rex        : "(?!#{predelimit})/.*/[img]{0,3}"
    precedents : ['note', 'string']

  symbol :
    color      : chalk.magenta
    rex        : "(?![#{predelimit}])[^#{postdelimit}]+"
    precedents : ['string','regex','note']
    subtype    : (value) ->
      if not isNaN(value)
        "number"
      else
        "symbol"

  delim :
    color      : chalk.white
    rex        : "[\\#{starts}\\#{ends}\\#{delimiters}]"
    precedents : ['string','symbol','regex','note']
    subtype    : (value) ->
      types =
        '(' : 'list'
        '[' : 'array'
        '{' : 'assoc'
        '<' : 'tuple'
      if _(_(types).keys()).contains(value)
        types[value]
      else
        "delim"

  note :
    color      : chalk.green
    rex        : ";.*$"
    precedents : []

  indent :
    color      : chalk.gray
    rex        : "^\\s+"
    precedents : []

exports.delimiters =
  starters : starters
  enders   : enders
  enderof  : enderof

exports.root = () -> _(
  color  : chalk.gray
  type   : 'root'
  value  : ""
  index  : 0
  ends   : 0
  line   : 0).clone()


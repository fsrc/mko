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
    rex        : "\".+\""
    precedents : ['note', 'regex']

  regex :
    rex        : "(?!#{predelimit})/.*/[img]{0,3}"
    precedents : ['note', 'string']

  atom :
    rex        : "(?![#{predelimit}])[^#{postdelimit}]+"
    precedents : ['string','regex','note']

  delim :
    rex        : "[\\#{starts}\\#{ends}\\#{delimiters}]"
    precedents : ['string','atom','regex','note']
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
    rex        : ";.*$"
    precedents : []

  indent :
    rex        : "^\\s+"
    precedents : []

exports.delimiters =
  starters : starters
  enders   : enders
  enderof  : enderof

exports.root = () -> _(
  type   : 'root'
  value  : ""
  index  : 0
  ends   : 0
  line   : 0
  column : 0).clone()

exports.grammar = (t) ->



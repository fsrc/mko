chalk = require("chalk")

starters = "\\[\\(\\{"
enders   = "\\]\\)\\}"
predelimit = "#{starters}\\s:^"
postdelimit = "#{enders}\\s:;$"
exports.newlinepattern = /\n/mg
exports.patterns =
  string  :
    color:chalk.yellow
    rex:"\".+\""
    precedents: ['comment', 'regex']

  regex   :
    color:chalk.red
    rex:"(?!#{predelimit})/.*/[img]{0,3}"
    precedents: ['comment', 'string']

  symbol  :
    color:chalk.magenta
    rex:"(?![#{predelimit}])[^#{postdelimit}]+"
    precedents: ['string','regex','comment']

  group   :
    color:chalk.white
    rex:"[#{starters}#{enders}]"
    precedents: ['string','symbol','regex','comment']

  comment :
    color:chalk.green
    rex:";.*$"
    precedents: []

  indent  :
    color:chalk.gray
    rex:"^\\s+"
    precedents: []



_ = require('underscore')
k = require('./common')

INCL = 'incl'
EXCL = 'excl'
START = 'start'
END = 'end'
DELIM = 'delim'
SINGLE = 'single'

defines = [
    #Token , Token Name , Function        , Group        , Group-function
    [ '('  , 'LPAREN'    , 'start-list'    , [['LIST'       , START  , INCL]]]
    [ ')'  , 'RPAREN'    , 'end-list'      , [['LIST'       , END    , INCL]
                                             ,['REGEX'      , END    , EXCL]]]

    [ '{'  , 'LBRACE'    , 'start-assoc'   , [['ASSOC'      , START  , INCL]]]
    [ ':'  , 'COLON'     , 'delimit-assoc' , [['ASSOC'      , DELIM  , INCL]]]
    [ '}'  , 'RBRACE'    , 'end-assoc'     , [['ASSOC'      , END    , INCL]]]
    [ '<'  , 'LARROW'    , 'start-tuple'   , [['TUPLE'      , START  , INCL]]]
    [ '>'  , 'RARROW'    , 'end-tuple'     , [['TUPLE'      , END    , INCL]]]
    [ '['  , 'LBRACK'    , 'start-array'   , [['ARRAY'      , START  , INCL]]]
    [ ']'  , 'RBRACK'    , 'end-array'     , [['ARRAY'      , END    , INCL]]]
    [ '\'' , 'SQUOTE'    , 'quote'         , [['QUOTE'      , SINGLE , INCL]]]

    [ '/'  , 'SLASH'     , 'regex'         , [['REGEX'      , START  , INCL]
                                             ,['REGEX'      , DELIM  , INCL]]]

    [ '"'  , 'DQUOTE'    , 'string'        , [['STRING'     , START  , INCL]
                                             ,['STRING'     , END    , INCL]]]

    [ ' '  , 'SPACE'     , 'space'         , [['WHITESPACE' , SINGLE , INCL]
                                             ,['REGEX'      , END    , EXCL]]]

    [ '\t' , 'TAB'       , 'tab'           , [['WHITESPACE' , SINGLE , INCL]]]

    [ '\n' , 'NEWLINE'   , 'newline'       , [['NEWLINE'    , SINGLE , INCL]
                                              ['COMMENT'    , END    , EXCL]
                                              ['REGEX'      , END    , EXCL]]]

    [ ';'  , 'SEMICOLON' , 'comment'       , [['COMMENT'    , START  , INCL]]]]

lexemes = _(defines).map((row) ->
  lexeme =
    reserved:true
    hasToken:(input) -> input == row[0]
    hasTokenName:(input) -> input == row[1]
    hasFunction:(input) -> input == row[2]
    inGroup:(input) -> _(row[3]).find((group) -> group[0] == input)?
    token:row[0]
    tokenName:row[1]
    function:row[2]
    groups: _(row[3]).map((group) ->
      name:group[0]
      function:group[1]
      inclusive:group[2])
  _(lexeme.groups).each((group) ->
    lexeme[group.name] ?= {}
    lexeme[group.name][group.function] = group)
  lexeme)

tokens     = _(lexemes).indexBy((row) -> row.token)
tokenNames = _(lexemes).indexBy((row) -> row.tokenNames)
functions  = _(lexemes).indexBy((row) -> row.functions)
groups     = _(lexemes).reduce((groups, row) ->
  _(row.groups).each((group) ->
    groups[group.name] ?= { name: group.name }
    groups[group.name][group.function] = row)
  groups
,{})

module.exports = c = (input) ->
  if not input?                    then lexemes
  else if _(tokens).has(input)     then tokens[input]
  else if _(tokenNames).has(input) then tokenNames[input]
  else if _(functions).has(input)  then functions[input]
  else if _(groups).has(input)     then groups[input]
  else
    reserved:false
    hasToken:() -> false
    hasTokenName:() -> false
    hasFunction:() -> false
    inGroup:() -> false

#k.inspect groups
#k.log "STRING"
#k.inspect c("WHITESPACE")

_ = require('underscore')

defines = [
    #Token , Token Name , Function        , Group        , Group-function
    [ '('  , 'LPAREN'    , 'start-list'    , [['LIST'       , 'start'  ]]]
    [ ')'  , 'RPAREN'    , 'end-list'      , [['LIST'       , 'end'    ]]]
    [ '{'  , 'LBRACE'    , 'start-assoc'   , [['ASSOC'      , 'start'  ]]]
    [ ':'  , 'COLON'     , 'delimit-assoc' , [['ASSOC'      , 'delim'  ]]]
    [ '}'  , 'RBRACE'    , 'end-assoc'     , [['ASSOC'      , 'end'    ]]]
    [ '<'  , 'LARROW'    , 'start-tuple'   , [['TUPLE'      , 'start'  ]]]
    [ '>'  , 'RARROW'    , 'end-tuple'     , [['TUPLE'      , 'end'    ]]]
    [ '['  , 'LBRACK'    , 'start-array'   , [['ARRAY'      , 'start'  ]]]
    [ ']'  , 'RBRACK'    , 'end-array'     , [['ARRAY'      , 'end'    ]]]
    [ '\'' , 'SQUOTE'    , 'quote'         , [['QUOTE'      , 'single' ]]]

    [ '/'  , 'SLASH'     , 'regex'         , [['REGEX'      , 'start'  ]
                                             ,['REGEX'      , 'delim'  ]]]

    [ '"'  , 'DQUOTE'    , 'string'        , [['STRING'     , 'start'  ]
                                             ,['STRING'     , 'end'    ]]]

    [ ' '  , 'SPACE'     , 'space'         , [['WHITESPACE' , 'single' ]
                                             ,['REGEX'      , 'end'    ]]]

    [ '\t' , 'TAB'       , 'tab'           , [['WHITESPACE' , 'single' ]]]

    [ '\n' , 'NEWLINE'   , 'newline'       , [['NEWLINE'    , 'single' ]
                                              ['COMMENT'    , 'end'    ]]]

    [ ';'  , 'SEMICOLON' , 'comment'       , [['COMMENT'    , 'start'  ]]]]

lexemes = _(defines).map((row) ->
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
    function:group[1]))

tokens     = _(lexemes).indexBy((row) -> row.token)
tokenNames = _(lexemes).indexBy((row) -> row.tokenNames)
functions  = _(lexemes).indexBy((row) -> row.functions)
groups     = _(lexemes).reduce((groups, row) ->
  _(row.groups).each((group) ->
    groups[group.name] ?= {}
    groups[group.name][group.function] = row)
  groups
,{})

console.dir groups
module.exports = (input) ->
  if not input?                    then lexemes
  else if _(tokens).has(input)     then tokens[input]
  else if _(tokenNames).has(input) then tokenNames[input]
  else if _(functions).has(input)  then functions[input]
  else if _(groups).has(input)     then functions[input]
  else
    reserved:false
    hasToken:() -> false
    hasTokenName:() -> false
    hasFunction:() -> false
    inGroup:() -> false


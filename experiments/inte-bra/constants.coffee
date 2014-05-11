_ = require('underscore')
k = require('./common')

INCL = 'incl'
EXCL = 'excl'
START = 'start'
END = 'end'
DELIM = 'delim'
ATOM = 'atom'
DUMMY = {
  reserved:false
  tokenName : "SYMBOL"
  function  : "symbol"
  hasToken:() -> false
  hasTokenName:() -> false
  hasFunction:() -> false
  inContext:() -> false
  isStarter:false
  isEnder:false
  isEnderOf:(input) -> false
  isDelimiter:false
  isAtom:false
  contexts:[{
    name:'SYMBOL'
    function:ATOM
    inclusive:INCL}]
}
#Token , Token Name , Function        , Context        , Context-function
startList     = [ '('  , 'LPAREN'    , 'start-list'    , [['LIST'      , START, INCL, DUMMY]], ')']
endList       = [ ')'  , 'RPAREN'    , 'end-list'      , [['LIST'      , END  , INCL, startList]
                                                         ,['REGEX'     , END  , EXCL, DUMMY]]]

startAssoc    = [ '{'  , 'LBRACE'    , 'start-assoc'   , [['ASSOC'     , START, INCL, DUMMY]], '}']
delimitAssoc  = [ ':'  , 'COLON'     , 'delimit-assoc' , [['ASSOC'     , DELIM, INCL, DUMMY]]]
endAssoc      = [ '}'  , 'RBRACE'    , 'end-assoc'     , [['ASSOC'     , END  , INCL, startAssoc]]]
startTuple    = [ '<'  , 'LARROW'    , 'start-tuple'   , [['TUPLE'     , START, INCL, DUMMY]], '>']
endTuple      = [ '>'  , 'RARROW'    , 'end-tuple'     , [['TUPLE'     , END  , INCL, startTuple]]]
startArray    = [ '['  , 'LBRACK'    , 'start-array'   , [['ARRAY'     , START, INCL, DUMMY]], ']']
endArray      = [ ']'  , 'RBRACK'    , 'end-array'     , [['ARRAY'     , END  , INCL, startArray]]]
quote         = [ '\'' , 'SQUOTE'    , 'quote'         , [['QUOTE'     , ATOM , INCL, DUMMY]]]

regex         = [ '/'  , 'SLASH'     , 'regex'         , [['REGEX'     , START, INCL, DUMMY]
                                                         ,['REGEX'     , DELIM, INCL, DUMMY]], ' \n\t)}>]']

string        = [ '"'  , 'DQUOTE'    , 'string'        , [['STRING'    , START, INCL, DUMMY]
                                                         ,['STRING'    , END  , INCL, string]], '"']

space         = [ ' '  , 'SPACE'     , 'space'         , [['WHITESPACE', ATOM , INCL, DUMMY]
                                                         ,['REGEX'     , END  , EXCL, regex]]]

tab           = [ '\t' , 'TAB'       , 'tab'           , [['WHITESPACE', ATOM , INCL, DUMMY]]]

comment       = [ ';'  , 'SEMICOLON' , 'comment'       , [['COMMENT'   , START, INCL, DUMMY]], '\n']

newline       = [ '\n' , 'NEWLINE'   , 'newline'       , [['NEWLINE'   , ATOM , INCL, DUMMY]
                                                          ['COMMENT'   , END  , EXCL, comment]
                                                          ['REGEX'     , END  , EXCL, regex]]]


beginFile     = [ ''   , 'BOF',        'begin-file'    , [['FILE'      , START, EXCL, DUMMY]]]
endFile       = [ ''   , 'EOF',        'end-file'      , [['FILE'      , END  , INCL, DUMMY]]]


defines = [
  startList
  endList
  startAssoc
  delimitAssoc
  endAssoc
  startTuple
  endTuple
  startArray
  endArray
  quote
  regex
  string
  space
  tab
  newline
  comment
]

lexemes = _(defines).map((row) ->
  lexeme =
    reserved  : true
    token     : row[0]
    tokenName : row[1]
    function  : row[2]
    contexts  : _(row[3]).map((context) ->
      name      : context[0]
      function  : context[1]
      inclusive : context[2]
      ref       : context[3])
    finalizer : row[4]
  lexeme = _(lexeme).extend(
    hasToken     : (input) ->
      input == lexeme.token
    hasTokenName : (input) ->
      input == lexeme.tokenName
    hasFunction  : (input) ->
      input == lexeme.function
    inContext    : (input) -> _(lexeme.contexts).find((context) ->
      context.name == input)?
    isStarter    : _(lexeme.contexts).any((context) ->
      context.function == START)
    isEnder      : _(lexeme.contexts).any((context) ->
      context.function == END)
    isDelimiter  : _(lexeme.contexts).any((context) ->
      context.function == DELIM)
    isAtom       : _(lexeme.contexts).any((context) ->
      context.function == ATOM)
    isEnderOf    : (input) ->
      starterContext = _(input.contexts).findWhere(function:'start').name
      lexeme[starterContext]?.end?
    isFinalizer  : (input) ->
      lexeme.finalizer.indexOf(input) != -1
  )
  _(lexeme.contexts).each((context) ->
    lexeme[context.name] ?= {}
    lexeme[context.name][context.function] = context)
  lexeme)

tokens     = _(lexemes).indexBy((row) -> row.token)
tokenNames = _(lexemes).indexBy((row) -> row.tokenNames)
functions  = _(lexemes).indexBy((row) -> row.functions)
contexts   = _(lexemes).reduce((contexts, row) ->
  _(row.contexts).each((context) ->
    contexts[context.name] ?= { name: context.name }
    contexts[context.name][context.function] = row
    contexts[context.name])
  contexts
,{})

module.exports = c = (input) ->
  if not input?                    then lexemes
  else if _(tokens).has(input)     then tokens[input]
  else if _(tokenNames).has(input) then tokenNames[input]
  else if _(functions).has(input)  then functions[input]
  else if _(contexts).has(input)   then contexts[input]
  else DUMMY
#k.inspect contexts
#k.log "STRING"
#k.inspect c("WHITESPACE")

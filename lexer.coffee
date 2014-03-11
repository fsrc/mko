_ = require('underscore')
async = require('async')
k = require('./common')
c = require('./constants')


newSymbol = (char, row, col) ->
  token:char
  row:row
  col:col
  len:1

appendSymbol = (a, char) ->
  k.set(a, (n) ->
    n.token += char
    n.len += char.length
    n)

toSymbols = (out, char) ->
  out.push(
    if c(char).reserved then newSymbol(char, @row, @col)
    else if c(_(out).last().token).reserved then newSymbol(char, @row, @col)
    else appendSymbol(out.pop(), char))
  @col += 1
  if c(char).hasTokenName('NEWLINE')
    @col = 1
    @row += 1
  out

composeGroup = (out, symbol) ->
  @state = "FIND FIRST" if not @state?
  symbolFunction = c(symbol.token)[@group.name]
  out.push(
    if @state == "FIND FIRST"
      if symbolFunction?.start
        @state = "FIND NEXT"
        symbol.group = @group.name
      symbol
    else if @state == "FIND NEXT"
      if symbolFunction?.end
        @state = "FIND FIRST"
        if symbolFunction.end.inclusive == "incl"
          appendSymbol(out.pop(), symbol.token)
        else if symbolFunction.end.inclusive == "excl"
          symbol
        else
          throw "Internal Error in symbol definition"
      else
        appendSymbol(out.pop(), symbol.token)
    else
      throw "Compose group @state error. State: #{@state}")
  out

onlyMembers = (out, symbol) ->
  @state = "FIND FIRST" if not @state?
  out.push(
    if @state == "FIND FIRST"
      if c(symbol.token).inGroup(@group.name)
        @state = "FIND NEXT"
        symbol.group = @group.name
      symbol
    else if @state == "FIND NEXT"
      if not c(symbol.token).inGroup(@group.name)
        @state = "FIND FIRST"
        symbol
      else
        appendSymbol(out.pop(), symbol.token)
    else
      throw "Only members @state error. State: #{@state}")

  out

#composeStrings = async.apply(composeGroup, c('STRING'))

lex = (input) ->
  _.chain(input)
    .reduce(toSymbols,[],{row:1,col:1})
    .reduce(composeGroup, [], group:c("STRING"))
    .reduce(composeGroup, [], group:c("COMMENT"))
    .reduce(composeGroup, [], group:c("REGEX"))
    .reduce(onlyMembers, [], group:c('WHITESPACE'))
    .value()


if not module.parent?
  fs   = require('fs')
  filename = process.argv[2]

  if not filename?
    k.log("You must provide a file to be lexed")
  else
    k.log("Reading file '#{filename}'")
    fs.readFile(filename, encoding:'utf8', (err, raw) ->
      k.log("Lexing..")
      lexed = lex(raw)
      k.inspect(_(lexed).last(6))
      k.log("Number of tokens: #{lexed.length}"))
    #)

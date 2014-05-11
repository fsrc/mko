_     = require('underscore')
async = require('async')
k     = require('./common')
c     = require('./constants')


newSymbol = (char, row, col, definition) ->
  token:char
  row:row
  col:col
  len:1
  def:definition

appendSymbol = (a, char) ->
  _(a).set((n) ->
    n.token += char
    n.len += char.length
    n)

toSymbols = (out, char) ->
  out.push(
    if c(char).reserved then newSymbol(char, @row, @col, c(char))
    else if c(_(out).last().token).reserved then newSymbol(char, @row, @col, c(char))
    else appendSymbol(out.pop(), char))
  @col += 1
  if c(char).hasTokenName('NEWLINE')
    @col = 1
    @row += 1
  out

composeGroup = (out, symbol) ->
  @state = "FIND FIRST" if not @state?
  symbolFunction = c(symbol.token)[@context.name]
  out.push(
    if @state == "FIND FIRST"
      if symbolFunction?.start
        @state = "FIND NEXT"
        symbol.context = @context.name
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
      throw "Compose context @state error. State: #{@state}")
  out

onlyMembers = (out, symbol) ->
  @state = "FIND FIRST" if not @state?
  out.push(
    if @state == "FIND FIRST"
      if c(symbol.token).inContext(@context.name)
        @state = "FIND NEXT"
        symbol.context = @context.name
      symbol
    else if @state == "FIND NEXT"
      if not c(symbol.token).inContext(@context.name)
        @state = "FIND FIRST"
        symbol
      else
        appendSymbol(out.pop(), symbol.token)
    else
      throw "Only members @state error. State: #{@state}")
  out

lex = (input) ->
  _.chain(input)
    .reduce(toSymbols,[],{row:1,col:1})
    #.reduce(composeGroup, [], context:c("COMMENT"))
    #.reduce(onlyMembers, [], context:c('WHITESPACE'))
    .value()

restruct = (token_array) ->
  restructure = (token_array, offset = 0, starter) ->
    struct = []
    while offset < token_array.length
      token = token_array[offset]
      if token.def.isStarter
        [offset, tmp_array] = restructure(token_array, offset + 1, token)
        struct.push(_({}).extend(token, {value:tmp_array}))
      else
        struct.push(token_array[offset])
        if starter?.def.isFinalizer(token.token)
          break
      offset += 1
    return [offset, struct]

  restructure(token_array, 0, null).pop()

print = (list, indent) ->
  _(list).eachNode((item) ->
    _(item.token).out())

if not module.parent?
  fs = require('fs')
  filename = process.argv[2]

  if not filename?
    _.log("You must provide a file to be lexed")
  else
    _.log("Reading file '#{filename}'")
    fs.readFile(filename, encoding:'utf8', (err, raw) ->
      lexed = lex(raw)
      ast = restruct(lexed)
      ast = _(ast).filterTree((node) ->
        node.def.function != "comment")
      fs.writeFile("#{filename}.lex", JSON.stringify(ast), encoding:'utf8', (err) ->
        _.log("Done"))
    )


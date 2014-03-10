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

joinSymbols = (group, out, symbol) ->
  out.push(
    if c(symbol.token).inGroup(group) and not @delim
      @delim = true
      symbol.type = group
      symbol
    else if c(symbol.token).inGroup(group) and @delim
      @delim = false
      appendSymbol(out.pop(), symbol.token)
    else if @delim
      appendSymbol(out.pop(), symbol.token)
    else
      symbol)
  out

onlyMembers = (group, out, symbol) ->
  out.push(
    if c(symbol.token).inGroup(group) and not @delim
      @delim = true
      symbol.type = group
      symbol
    else if c(symbol.token).inGroup(group) and @delim
      appendSymbol(out.pop(), symbol.token)
    else
      @delim = false
      symbol)
  out


lex = (input) ->
  _.chain(input)
    .reduce(toSymbols,[],{row:1,col:1})
    .reduce(async.apply(joinSymbols, 'STRING'), [], {delim:false})
    .reduce(async.apply(onlyMembers, 'WHITESPACE'), [], {delim:false})
    #.reduce(async.apply(joinSymbols, 'COMMENT'), [], {delim:false})
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
      k.inspect(lexed))

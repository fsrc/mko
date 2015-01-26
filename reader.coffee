_ = require("lodash")
fs = require('fs')

delimiters  = _(['(',')','[',']','{','}',"<",">"])
space       = _([' ','\t'])
linefeed    = _(['\n'])
starters    = _(['(','[','{',"<"])
enders      = _([')',']','}',">"])
quotes      = _(['"', "'"])
esc         = _(['\\'])
comment     = _([';'])
pairs =
  "(" : ")"
  "[" : "]"
  "{" : "}"
  "<" : ">"
  "'" : "'"
  ";" : "\n"
  '"' : '"'

camelCase = (str) ->
  str.replace(/(?:_| |\b)(\w)/g, (str, p1) ->
      p1.toUpperCase())

endsWith = (str, suffix) ->
  str.indexOf(suffix, str.length - suffix.length) != -1

test = (type, char) ->
  type.contains(char.char)

promise = (events) ->
  _.reduce(events, (acc, event) ->
    name = camelCase(event)
    acc[event] = () ->
    acc["on#{name}"] = (handler) ->
      acc[event] = handler
      acc
    acc
  , { events: events })

exports.file = file = (fname) ->
  strm = fs.createReadStream(fname,
    flags:'r'
    encoding:'utf8'
    autoClose:true)

charReader = (strm) ->
  do (strm) ->
    p = promise(['char', 'error', 'end'])
    strm.on('error', (error) -> p.error(error))
    strm.on('end', () -> p.end())
    strm.on('close', () -> console.log("stream closed"))
    strm.on('data', (data) ->
      _.reduce(data, (acc, char) ->
        p.char(
          char:char
          row:acc.row
          col:acc.col)
        if test(linefeed,char)
          acc.row += 1
          acc.col = 0
        else
          acc.col += 1
        acc
      , {row:0, col:0}))
    p

stringMerger = (strm) ->
  do (strm) ->
    p = promise(['token', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())
    state = null

    strm.onChar((char) ->
      if test(quotes, char)
        if not state?
          state = {char:[char]}
        else if test(esc, _.last(state.char))
          state.char.push(char)
        else
          state.char.push(char)
          p.token(
            char:_.pluck(state.char, 'char').join('')
            type:'string'
            row:state.char[0].row
            col:state.char[0].col)
          state = null

      else if state?
        state.char.push(char)

      else
        p.token(char))
    p

commentMerger = (strm) ->
  do (strm) ->
    p = promise(['token', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())
    state = null

    strm.onChar((char) ->
      if test(comment, char)
        state = [char]
      else
        p.token(char))
    p

symbolMerger = (strm) ->
  do (strm) ->
    p = promise(['token', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())
    state = null

    strm.onChar((char) ->
        p.token(char))
    p

if module.parent == null
  infile = process.argv[2]
  console.log "Input file: #{infile}"

  stringMerger(charReader(file(infile)))
    .onToken((token) -> console.log(token))
    .onError((error) -> console.log(error))
    .onEnd(() -> console.log("Done"))


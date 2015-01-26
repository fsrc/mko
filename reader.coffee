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

test = (type, atom) ->
  type.contains(atom.char)

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
    p = promise(['atom', 'error', 'end'])
    strm.on('error', (error) -> p.error(error))
    strm.on('end', () -> p.end())
    strm.on('close', () -> console.log("stream closed"))
    strm.on('data', (data) ->
      _.reduce(data, (acc, char) ->
        atom =
          row:acc.row
          col:acc.col
          char:char
        if test(linefeed, atom)
          p.atom(_.assign(type:'lbr', atom))
          acc.row += 1
          acc.col = 1
        else
          p.atom(atom)
          acc.col += 1
        acc
      , {row:1, col:1}))
    p

stringMerger = (strm) ->
  do (strm) ->
    p = promise(['atom', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())
    state = null

    strm.onAtom((atom) ->
      if test(quotes, atom)
        if not state?
          state = {atom:[atom]}
        else if test(esc, _.last(state.atom))
          state.atom.push(atom)
        else
          state.atom.push(atom)
          p.atom(
            type:'str'
            row:state.atom[0].row
            col:state.atom[0].col
            char:_.pluck(state.atom, 'char').join(''))
          state = null

      else if state?
        state.atom.push(atom)

      else
        p.atom(atom))
    p

commentMerger = (strm) ->
  do (strm) ->
    p = promise(['atom', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())
    state = null

    strm.onAtom((atom) ->
      if state?
        if test(linefeed, atom)
          p.atom(
            type:'com'
            row:state.atom[0].row
            col:state.atom[0].col
            char:_.pluck(state.atom, 'char').join(''))
          state = null
        else
          state.atom.push(atom)
      else if test(comment, atom)
        state = {atom:[atom]}
      else
        p.atom(atom))
    p

spaceMerger = (strm) ->
  do (strm) ->
    p = promise(['atom', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())
    state = null

    strm.onAtom((atom) ->
      if state?
        if not test(space, atom)
          p.atom(
            type:'spa'
            row:state.atom[0].row
            col:state.atom[0].col
            char:_.pluck(state.atom, 'char').join(''))
          p.atom(atom)
          state = null
        else
          state.atom.push(atom)

      else if test(space, atom)
        state = {atom:[atom]}

      else
        p.atom(atom))
    p

classifyDelimiters = (strm) ->
  do (strm) ->
    p = promise(['atom', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())

    strm.onAtom((atom) ->
      if test(delimiters, atom)
        p.atom(
          type:'del'
          row:atom.row
          col:atom.col
          char:atom.char)
      else
        p.atom(atom))
    p

symbolMerger = (strm) ->
  do (strm) ->
    p = promise(['atom', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())
    state = null

    strm.onAtom((atom) ->
      if atom.type?
        if state?
          p.atom(
            type:'sym'
            row:state.atom[0].row
            col:state.atom[0].col
            char:_.pluck(state.atom, 'char').join(''))
          state = null
        p.atom(atom)
      else
        if state?
          state.atom.push(atom)
        else
          state = {atom:[atom]})
    p

if module.parent == null
  infile = process.argv[2]
  console.log "Input file: #{infile}"

  _.compose(
    symbolMerger
    classifyDelimiters
    spaceMerger
    commentMerger
    stringMerger
    charReader
    file)(infile)
    .onAtom((atom) -> console.log(atom))
    .onError((error) -> console.log(error))
    .onEnd(() -> console.log("Done"))


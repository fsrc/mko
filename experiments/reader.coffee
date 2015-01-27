_ = require("lodash")
fs = require('fs')

delimiters  = _(['(',')','[',']','{','}',';','"',"<",">"])
space       = _([' ','\t'])
linefeed    = _(['\n'])
starters    = _(['(','[','{',';',"<"])
enders      = _([')',']','}','\n',">"])
quotes      = _(['"', "'"])
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

promise = (events) ->
  _.reduce(events, (acc, event) ->
    name = camelCase(event)
    acc[event] = () ->
    acc["on#{name}"] = (handler) ->
      acc[event] = handler
      acc
    acc
  , { events: events })

exports.delimiter = delimiter = (strm) ->
  do (strm) ->
    state = {row:0,col:-1,be:0,tok:""}
    p = promise(['delimiter', 'error', 'end'])
    strm.on('error', (error) -> p.error(error))
    strm.on('end', () -> p.end())
    strm.on('close', () -> console.log("stream closed"))
    strm.on('data', (data) ->
      foldl = (acc, char) ->
        acc.col += 1
        # Found delimiter
        if delimiters.contains(char)
          # Handle any accumulated token
          if acc.tok != ""
            acc.en = acc.st
            p.delimiter(row:acc.row, st:acc.st, tok:acc.tok)
            acc.tok = ""
          # Handle delimiter token
          p.delimiter(row:acc.row, st:acc.col, tok:char)

        # Found space token
        else if space.contains(char)
          # If we don't have an acumulated token, start a space token
          if acc.tok == ""
            acc.st = acc.col
            acc.tok = char
          # If we have an space token, continue the token
          else if space.contains(acc.tok[0])
            acc.tok += char
          # If we have another accumulated token
          else if acc.tok != ""
            p.delimiter(row:acc.row, st:acc.st, tok:acc.tok)
            acc.tok = char
          # In all other cases
          else
            console.log "WARNING strange hase in space token"
            p.delimiter(acc)
            acc.tok = ""

        # If we have linefeed
        else if linefeed.contains(char)
          # If we have accumulation going on
          if acc.tok != ""
            p.delimiter(row:acc.row, st:acc.st, tok:acc.tok)
            acc.tok = ""

          # Take care of the linefeed
          p.delimiter(row:acc.row, st:acc.col, tok:char)
          acc.row += 1
          acc.col = -1

        # Any other character would end up accumulating here
        else
          # Start a new accumulation
          if acc.tok == ""
            acc.st = acc.col
            acc.tok = char
          # If we have a space accumulation going on, end it
          else if space.contains(acc.tok[0])
            p.delimiter(row:acc.row, st:acc.st, tok:acc.tok)
            acc.tok = char
          # Else continue accumulate
          else
            acc.tok += char

        # Finally pass on state to next roundtrip
        acc

      state = _.reduce(data, foldl, state))
    p

parser = () ->
  do () ->
    state = { force:null, value:null }
    p = promise(['starter', 'ender', 'other', 'space', 'quote'])
    p['digest'] = (delim) ->
      if state.force?
        state = p[state.force](state, delim)
      else if space.contains(delim.tok[0])
        state = p.space(state, delim)
      else if quotes.contains(delim.tok)
        state = p.quote(state, delim)
      else if starters.contains(delim.tok)
        state = p.starter(state, delim)
      else if enders.contains(delim.tok)
        state = p.ender(state, delim)
      else
        state = p.other(state, delim)
    p

exports.reader = reader = (delimiter) ->
  do (delimiter) ->
    parser = parser()
      .onSpace((state, char) ->
        console.log "Space", char
        state)
      .onQuote((state, char) ->
        if state.force == 'quote'
          state.force = null
        else
          state.force = 'quote'
        console.log "Quote", char
        state)
      .onStarter((state, char) ->
        console.log "Starter", char
        state)
      .onEnder((state, char) ->
        console.log "Ender", char
        state)
      .onOther((state, char) ->
        console.log "Other", char
        state)

    p = promise(['token', 'error', 'end'])
    delimiter.onError((error) -> p.error())
    delimiter.onEnd(() -> p.end())
    delimiter.onDelimiter(parser.digest)
    p

exports.file = file = (fname) ->
  strm = fs.createReadStream(fname,
    flags:'r'
    encoding:'utf8'
    autoClose:true)


if module.parent == null
  infile = process.argv[2]
  console.log "Input file: #{infile}"

  reader(delimiter(file(infile)))
    .onToken((token) -> console.log(token))
    .onError((error) -> console.log(error))
    .onEnd(() -> console.log("Done"))


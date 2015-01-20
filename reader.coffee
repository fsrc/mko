_ = require("lodash")
fs = require('fs')

delimiters = _(['(',')','[',']','{','}',';','"',"<",">"])
space      = _([' ','\t'])
linefeed   = _(['\n'])

exports.reader = reader = (strm) ->
  do (strm) ->
    state = {row:0,col:-1,be:0,tok:""}
    handleToken = () ->
    handleError = () ->
    handleEnd = () ->
    prom =
      onToken:(handler) ->
        handleToken = handler
        prom
      onError:(handler) ->
        handleError = handler
        prom
      onEnd:(handler) ->
        handleEnd = handler
        prom

    strm.on('error', (error) -> handleError(error))
    strm.on('data', (data) ->
      foldl = (acc, char) ->
        acc.col += 1
        # Found delimiter
        if delimiters.contains(char)
          # Handle any accumulated token
          if acc.tok != ""
            acc.en = acc.st
            handleToken(row:acc.row, st:acc.st, tok:acc.tok)
            acc.tok = ""
          # Handle delimiter token
          handleToken(row:acc.row, st:acc.col, tok:char)

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
            handleToken(row:acc.row, st:acc.st, tok:acc.tok)
            acc.tok = char
          # In all other cases
          else
            console.log "WARNING strange hase in space token"
            handleToken(acc)
            acc.tok = ""

        # If we have linefeed
        else if linefeed.contains(char)
          # If we have accumulation going on
          if acc.tok != ""
            handleToken(row:acc.row, st:acc.st, tok:acc.tok)
            acc.tok = ""

          # Take care of the linefeed
          handleToken(row:acc.row, st:acc.col, tok:char)
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
            handleToken(row:acc.row, st:acc.st, tok:acc.tok)
            acc.tok = char
          # Else continue accumulate
          else
            acc.tok += char

        # Finally pass on state to next roundtrip
        acc

      state = _.reduce(data, foldl, state))
    strm.on('end', () -> handleEnd())
    strm.on('close', () -> console.log("stream closed"))

    prom

exports.file = file = (fname) ->
  strm = fs.createReadStream(fname,
    flags:'r'
    encoding:'utf8'
    autoClose:true)


if module.parent == null
  infile = process.argv[2]
  console.log "Input file: #{infile}"

  reader(file(infile))
    .onToken((token) -> console.log(token))
    .onError((error) -> console.log(error))
    .onEnd(() -> console.log("Done"))

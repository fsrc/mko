_       = require('lodash')
promise = require('../promise')
test    = require('../helpers').test

module.exports = (rules, strm) ->
  do (rules, strm) ->
    state = {row:1, col:1}
    p = promise(['char', 'error', 'end'])
    strm.on('error', (error) -> p.error(error))
    strm.on('end', () ->
      p.char(row:state.row, col:state.col, str:"\0")
      p.end())
    strm.on('close', () -> )
    strm.on('data', (data) ->
      state = _.reduce(data, (acc, char) ->
        char =
          row:acc.row
          col:acc.col
          str:char
        if test(rules.classes.linefeed, char)
          p.char(char)
          acc.row += 1
          acc.col = 1
        else
          p.char(char)
          acc.col += 1
        acc
      , state))
    p

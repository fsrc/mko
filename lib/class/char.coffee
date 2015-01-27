_ = require('lodash')
promise = require('../promise')
test = require('../helpers').test

module.exports = (rules, strm) ->
  do (rules, strm) ->
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
        if test(rules.linefeed, atom)
          p.atom(_.assign(type:'lbr', atom))
          acc.row += 1
          acc.col = 1
        else
          p.atom(atom)
          acc.col += 1
        acc
      , {row:1, col:1}))
    p

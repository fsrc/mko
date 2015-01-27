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
          r:acc.r
          c:acc.c
          ch:char
        if test(rules.linefeed, atom)
          p.atom(_.assign(t:'lb', atom))
          acc.r += 1
          acc.c = 1
        else
          p.atom(atom)
          acc.c += 1
        acc
      , {r:1, c:1}))
    p

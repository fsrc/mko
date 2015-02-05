_       = require('lodash')
promise = require('../promise')
test    = require('../helpers').test

module.exports = (rules, strm) ->
  do (rules, strm) ->
    p = promise(['atom', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())

    strm.onAtom((atom) ->
      if test(rules.delimiters, atom)
        p.atom(
          t:'de'
          r:atom.r
          c:atom.c
          ch:atom.ch)
      else
        p.atom(atom))
    p

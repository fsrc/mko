_ = require('lodash')
promise = require('../promise')
test = require('../helpers').test

module.exports = (rules, strm) ->
  do (rules, strm) ->
    p = promise(['atom', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())

    strm.onAtom((atom) ->
      if test(rules.delimiters, atom)
        p.atom(
          type:'del'
          row:atom.row
          col:atom.col
          char:atom.char)
      else
        p.atom(atom))
    p

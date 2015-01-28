_       = require('lodash')
promise = require('../promise')

evaluator = () ->

module.exports = (rules, strm) ->
  do (rules, strm) ->
    p = promise(['atom', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())
    state = null

    strm.onAtom((atom) ->
      if atom.t == 'sy' and atom.ch == 'rec'
        atom.eval = evaluator
        console.log atom
      p.atom(atom)
    )
    p

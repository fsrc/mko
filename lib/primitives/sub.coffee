_       = require('lodash')
promise = require('../promise')

evaluator = (args...) ->
  _.reduce(_.rest(args...), (acc, arg) ->
    acc - arg
  , _.first(args...))

module.exports = (rules, strm) ->
  do (rules, strm) ->
    p = promise(['atom', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())
    state = null

    strm.onAtom((atom) ->
      if atom.t == 'sy' and atom.ch == 'sub'
        atom.eval = evaluator
      p.atom(atom)
    )
    p
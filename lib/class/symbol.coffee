_ = require('lodash')
promise = require('../promise')

module.exports = (rules, strm) ->
  do (rules, strm) ->
    p = promise(['atom', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())
    state = null

    strm.onAtom((atom) ->
      if atom.t?
        if state?
          p.atom(
            t:'sy'
            r:state.atom[0].r
            c:state.atom[0].c
            ch:_.pluck(state.atom, 'ch').join(''))
          state = null
        p.atom(atom)
      else
        if state?
          state.atom.push(atom)
        else
          state = {atom:[atom]})
    p


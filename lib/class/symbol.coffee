_ = require('lodash')
promise = require('../promise')

module.exports = (rules, strm) ->
  do (rules, strm) ->
    p = promise(['atom', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())
    state = null

    strm.onAtom((atom) ->
      if atom.type?
        if state?
          p.atom(
            type:'sym'
            row:state.atom[0].row
            col:state.atom[0].col
            char:_.pluck(state.atom, 'char').join(''))
          state = null
        p.atom(atom)
      else
        if state?
          state.atom.push(atom)
        else
          state = {atom:[atom]})
    p


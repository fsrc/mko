_ = require('lodash')
promise = require('../promise')
test = require('../helpers').test

module.exports = (rules, strm) ->
  do (rules, strm) ->
    p = promise(['atom', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())
    state = null

    strm.onAtom((atom) ->
      if test(rules.quotes, atom)
        if not state?
          state = {atom:[atom]}
        else if test(rules.esc, _.last(state.atom))
          state.atom.push(atom)
        else
          state.atom.push(atom)
          p.atom(
            type:'str'
            row:state.atom[0].row
            col:state.atom[0].col
            char:_.pluck(state.atom, 'char').join(''))
          state = null

      else if state?
        state.atom.push(atom)

      else
        p.atom(atom))
    p

_ = require("lodash")
promise = require('../promise')
test = require('../helpers').test

module.exports = (rules, strm) ->
  do (rules, strm) ->
    p = promise(['atom', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())
    state = null

    strm.onAtom((atom) ->
      if state?
        if not test(rules.space, atom)
          p.atom(
            type:'spa'
            row:state.atom[0].row
            col:state.atom[0].col
            char:_.pluck(state.atom, 'char').join(''))
          p.atom(atom)
          state = null
        else
          state.atom.push(atom)

      else if test(rules.space, atom)
        state = {atom:[atom]}

      else
        p.atom(atom))
    p

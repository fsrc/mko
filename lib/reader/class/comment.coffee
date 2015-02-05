_       = require('lodash')
promise = require('../promise')
test    = require('../helpers').test

module.exports = (rules, strm) ->
  do (rules, strm) ->
    p = promise(['atom', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())
    state = null

    strm.onAtom((atom) ->
      if state?
        if test(rules.linefeed, atom)
          p.atom(
            t:'co'
            r:state.atom[0].r
            c:state.atom[0].c
            ch:_.pluck(state.atom, 'ch').join(''))
          state = null
        else
          state.atom.push(atom)
      else if test(rules.comment, atom)
        state = {atom:[atom]}
      else
        p.atom(atom))
    p

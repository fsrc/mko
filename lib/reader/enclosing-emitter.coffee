_       = require('lodash')
promise = require('../promise')

module.exports = (strm, start, end) ->
  do (strm, start, end) ->
    p       = promise(['atom', 'error', 'end'])
    state   = null

    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())

    newatom = (state) ->
      row:state.atom[0].row
      col:state.atom[0].col
      str:_.pluck(state.atom, 'str').join('')
      type:state.atom[0].type

    strm.onAtom((char) ->
      if not state?
        if char.type == start
          state = { atom: [char] }
        else
          p.atom(char)
      else
        state.atom.push(char)
        if char.type == end
          p.atom(newatom(state))
          state = null
    )
    p

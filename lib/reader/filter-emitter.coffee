_       = require('lodash')
promise = require('../promise')

module.exports = (chars, types...) ->
  do (strm) ->
    p       = promise(['atom', 'error', 'end'])
    state   = null
    types   = _(types)

    chars.onError((error) -> p.error(error))
    chars.onEnd(() -> p.end())

    newatom = (state) ->
      row:state.atom[0].row
      col:state.atom[0].col
      str:_.pluck(state.atom, 'str').join('')
      type:state.atom[0].type

    chars.onAtom((char) ->
      if not types.contains(char.type)
        p.atom(char)
    )
    p

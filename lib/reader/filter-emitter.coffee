_       = require('lodash')
promise = require('../promise')

module.exports = (strm, types...) ->
  do (strm, types) ->
    p       = promise(['atom', 'error', 'end'])
    state   = null
    types   = _(types)

    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())

    newatom = (state) ->
      row:state.atom[0].row
      col:state.atom[0].col
      str:_.pluck(state.atom, 'str').join('')
      type:state.atom[0].type

    strm.onAtom((char) ->
      if not types.contains(char.type)
        p.atom(char)
    )
    p

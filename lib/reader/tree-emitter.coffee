_       = require('lodash')
promise = require('../promise')

tree = (strm, rules) ->
  do (strm, rules) ->
    p       = promise(['atom', 'error', 'end'])
    state   = null
    types   = _(types)
    starters = _(rules.pairs).keys()
    state = []

    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())

    strm.onAtom((atom) ->
      current = _.last(state)
      if starters.contains(atom.str)
        console.log 'start'
        atom.children = []
        state.push(atom)
      else if current? and rules.pairs[current.str] == atom.str
        console.log 'end'
        state.pop()
        if state.length > 0
          parent = _.last(state)
          parent.children.push(current)
        else
          p.atom(current)
      else if current?
        current.children.push(atom)
        console.log "in the stack"
    )
    p


module.exports = tree

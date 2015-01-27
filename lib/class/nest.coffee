_ = require("lodash")
promise = require('../promise')
test = require('../helpers').test

module.exports = (rules, strm) ->
  do (rules, strm) ->
    p = promise(['atom', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())
    state = _([])

    strm.onAtom((atom) ->
      if test(rules.starters, atom)
        state.push(_(atom).assign(child:[]))
      else if test(rules.enders, atom)
        p.atom(state.pop())
      else if state.length > 0
        state.last().child.push(atom))
    p

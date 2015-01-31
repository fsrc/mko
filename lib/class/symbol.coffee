_       = require('lodash')
promise = require('../promise')

symbol = (form) ->
  intTest = /\d+/
  floatTest = /\d+\.\d+/

  if intTest.test(form.ch)
    dt:"int"
    val:parseInt(form.ch)
  else if floatTest.test(form.ch)
    dt:"float"
    val:parseFloat(form.ch)
  else
    dt:"var"
    val:form.ch

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


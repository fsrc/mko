_       = require('lodash')
promise = require('../promise')

evaluator = (form) ->
evalInt = (form) ->
  parseInt(form.ch)
evalFloat = (form) ->
  parseFloat(form.ch)

module.exports = (rules, strm) ->
  intTest = /\d+/
  floatTest = /\d+\.\d+/

  do (rules, strm) ->
    p = promise(['atom', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())
    state = null

    strm.onAtom((atom) ->
      if atom.t == 'sy'
        if atom.ch == 'int'
          atom.eval = evaluator
        else if intTest.test(atom.ch)
          atom.eval = evalInt
        else if floatTest.test(atom.ch)
          atom.eval = evalFloat
      p.atom(atom))
    p

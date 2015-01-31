_       = require('lodash')
promise = require('../promise')

evaluator = (form) ->
  items = _(form.des)
  items.first().eval(
    items.rest().map((item) ->
      item.eval(item)).value())

module.exports = (rules, strm) ->
  do (rules, strm) ->
    p = promise(['atom', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())
    state = null

    strm.onAtom((atom) ->
      if atom.t == 'de' and atom.ch == '('
        atom.eval = evaluator
      p.atom(atom)
    )
    p

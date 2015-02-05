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
      if test(rules.linefeed, atom) or
        test(rules.space, atom) or
        test(rules.comment, atom)
      else
        p.atom(atom))
    p

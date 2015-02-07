_       = require('lodash')
promise = require('../promise')
iftest    = require('../helpers').iftest

module.exports = (rules, strm) ->
  do (rules, strm) ->
    p = promise(['atom', 'error', 'end'])
    formtypes = _(rules.forms).keys().value()

    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())

    strm.onAtom((atom) ->
      if _.compact(_.map(formtypes, (type) ->
        iftest(rules.forms[type], atom, () ->
          p.atom(_.assign({ form:type }, atom))))).length == 0
        p.atom(atom))
    p

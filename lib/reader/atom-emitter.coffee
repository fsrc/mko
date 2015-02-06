_       = require('lodash')
promise = require('../promise')
test    = require('../helpers').test

module.exports = (rules, chars) ->
  do (rules, strm) ->
    p       = promise(['atom', 'error', 'end'])
    classes = _.values(rules.classes)
    state   = null

    chars.onError((error) -> p.error(error))
    chars.onEnd(() -> p.end())

    newstate = (char) ->
      match = _.find(classes, (match) -> match.test(char.str))
      if match?
        class : "delimiter"
        match  : match
        atom   : [char]
      else
        class : "symbol"
        atom   : [char]

    newatom = (state, type) ->
      row:state.atom[0].row
      col:state.atom[0].col
      str:_.pluck(state.atom, 'str').join('')
      type:_.findKey(rules.classes, (match) -> match == state.match) or "symbol"

    chars.onChar((char) ->
      if state?
        str = _.pluck(state.atom, 'str').join('') + char.str
        if state.match?.test(str)
          state.atom.push(char)
        else
          pendingstate = newstate(char)
          if pendingstate.class == state.class == "symbol"
            state.atom.push(char)
          else
            p.atom(newatom(state))
            state = pendingstate

      else
        state = newstate(char))

    p

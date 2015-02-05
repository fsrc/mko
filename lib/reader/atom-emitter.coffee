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
        symbol : false
        match  : match
        atom   : [char]
      else
        symbol : true
        atom   : [char]

    chars.onChar((char) ->
      if state? and not state.symbol
        str = _.pluck(state.atom, 'str').join('') + char.str
        if state.match.test(str)
          state.atom.push(char)
        else
          p.atom(
            row:state.atom[0].row
            col:state.atom[0].col
            str:_.pluck(state.atom, 'str').join('')
            type:_.findKey(rules.classes, (match) -> match == state.match))

          state = newstate(char)
      else if state? and state.symbol
        pendingstate = newstate(char)

        if pendingstate.symbol
          state.atom.push(char)
        else
          p.atom(
            row:state.atom[0].row
            col:state.atom[0].col
            str:_.pluck(state.atom, 'str').join('')
            type:'symbol')

          state = pendingstate

      else
        state = newstate(char))

    p

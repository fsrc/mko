_       = require("lodash")
promise = require('../promise')
test    = require('../helpers').test

indent = (amount, text) ->
  space = _([0..amount]).map((i) -> "  ").join('')
  console.log(space + text)

module.exports = (rules, strm) ->
  do (rules, strm) ->
    p = promise(['atom', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())
    stack = []

    strm.onAtom((atom) ->
      if test(rules.starters, atom)
        atom = _.assign({}, atom, des:[])
        if stack.length > 0
          asc = _.last(stack)
          asc.des.push(atom)
        stack.push(atom)

      else if test(rules.enders, atom)
        asc = stack.pop()
        if not asc? or not rules.pairs[asc.ch] == atom.ch
          return p.error(100, asc.r, asc.c, atom.r, atom.c) if asc?
          return p.error(101, atom.r, atom.c) if not asc?
        #asc.des.push(atom)
        if stack.length == 0
          p.atom(asc)
      else
        if stack.length > 0
          asc = _.last(stack)
          return p.error(100, asc.r, asc.c, atom.r, atom.c) if atom.t == 'eof'
          asc.des.push(atom))
    p

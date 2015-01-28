#!/bin/bash

function src {
  echo "_       = require('lodash')
promise = require('../promise')

evaluator = () ->

module.exports = (rules, strm) ->
  do (rules, strm) ->
    p = promise(['atom', 'error', 'end'])
    strm.onError((error) -> p.error(error))
    strm.onEnd(() -> p.end())
    state = null

    strm.onAtom((atom) ->
      if atom.t == 'sy' and atom.ch == '$1'
        atom.eval = evaluator
        console.log atom
      p.atom(atom)
    )
    p" > ./lib/primitives/$1.coffee
}
src def
src int
src str
src char
src date
src num
src bool

src list
src array
src object
src tuple

src quote
src fun
src mac

src either

src and
src or
src not
src xor

src rec
src use

src add
src sub
src div
src mul

src stdout
src errout
src stdin


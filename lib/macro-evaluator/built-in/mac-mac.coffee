_      = require('lodash')

module.exports = (name, arity, block...) ->
  if not arity?
    throw "ADD ERROR: Need arguments"
  if not block?
    throw "ADD ERROR: Need block"
  form:'macro'
  name:name.str
  arity:arity
  block:block

_      = require('lodash')

list = (array) ->
  form:'block'
  children:array

evaluate = (args..., evaluator, defines, macros, scope, arity, block) ->
  subscope = _.cloneDeep(scope)
  result = evaluator(list(block), subscope)
  return { value: result }


module.exports = (name, arity, block...) ->
  if not arity?
    throw "ADD ERROR: Need arguments"
  if not block?
    throw "ADD ERROR: Need block"
  form:'macro'
  name:name.str
  arity:arity
  block:block
  call:_.partialRight(evaluate, arity, block)

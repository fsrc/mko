_      = require('lodash')

list = (array) ->
  row:array[0]?.row
  col:array[0]?.col
  form:'block'
  children:array

evaluate = (args..., evaluator, defines, macros, scope, arity, block) ->
  console.log "In eval block ARITY", arity
  console.log "In eval block ARGS", args

  if args.length != arity.children.length
    throw "ADD ERROR: Wrong number of arguments"

  subscope = _.cloneDeep(scope)

  subscope = _(arity.children)
    .reduce((acc, child, index) ->
      acc[child.str] = args[index]
      acc
    , subscope.mac)

  console.log "In eval block SCOPE", subscope

  result = evaluator(list(block), subscope)
  return { value: result }


module.exports = (name, arity, block...) ->
  if not arity?
    throw "ADD ERROR: Macro needs arity"
  if not block?
    throw "ADD ERROR: Macro need block"
  form:'macro'
  name:name.str
  arity:arity
  block:block
  call:_.partialRight(evaluate, arity, block)

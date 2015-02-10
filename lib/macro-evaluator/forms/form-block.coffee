_ = require('lodash')
block_evaluator = require("./form-in-block")


module.exports = (block, evaluator, macros, scope) ->
  do (block, evaluator, macros, scope) ->
    subscope = _.cloneDeep(scope)
    _.reduce(
      block.children
      block_evaluator(
        evaluator
        macros
        subscope), null).value


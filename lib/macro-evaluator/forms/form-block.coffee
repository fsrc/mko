_ = require('lodash')

module.exports = (block, evaluator, macros, scope) ->
  do (block, scope) ->
    subscope = _.cloneDeep(scope)

    block_result = _.reduce(block.children, (acc, form) ->
      expanded = evaluator(form, subscope)

      if expanded.form == 'macro'
        console.log "In block, Registered macro #{expanded.name}"
        subscope.mac[expanded.name] = expanded

      else if expanded?
        console.log "In block, Form post macro expansion"
        expanded
    , null).value
    block_result


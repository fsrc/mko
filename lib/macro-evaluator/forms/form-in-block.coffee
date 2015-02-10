_ = require('lodash')

module.exports = (evaluator, macros, scope) ->
  do (evaluator, macros, scope) ->
    subscope = _.cloneDeep(scope)

    (last_result, form) ->
      last_result = evaluator(form, subscope)

      if last_result.form == 'macro'
        console.log "In block, Registered macro #{last_result.name}"
        subscope.mac[last_result.name] = last_result

      else if last_result?
        console.log "In block, Form post macro expansion"
        last_result

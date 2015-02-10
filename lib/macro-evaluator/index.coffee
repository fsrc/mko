_      = require('lodash')

evaluate = do () ->
  macros = require('./built-in')
  defines = require('./defines')
  forms = require('./forms')

  (form, scope) ->
    subscope = _.cloneDeep(scope)
    forms[form.form](form, evaluate, defines, macros, subscope)

module.exports = evaluate


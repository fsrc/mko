_      = require('lodash')

evaluate = do () ->
  macros = require('./built-in')
  defines = require('./defines')
  forms =
    list   : require('./forms/form-list')
    int    : require('./forms/form-int')
    number : require('./forms/form-number')
    string : require('./forms/form-string')
    symbol : require('./forms/form-symbol')
    block  : require('./forms/form-block')

  (form, scope) ->
    subscope = _.cloneDeep(scope)
    forms[form.form](form, evaluate, defines, macros, subscope)

module.exports = evaluate


_      = require('lodash')

evaluate = do () ->
  macros =
    mac : require('./built-in/mac-mac')
    use : require('./built-in/mac-use')
    add : require('./built-in/mac-add')

  forms =
    list   : require('./forms/form-list')
    int    : require('./forms/form-int')
    number : require('./forms/form-number')
    string : require('./forms/form-string')

  (form) ->
    forms[form.form](form, evaluate, macros)

module.exports = evaluate

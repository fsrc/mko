_      = require('lodash')

evaluate = do () ->
  macros =
    use : require('./built-in/mac-use')
    add : require('./built-in/mac-add')
    sub : require('./built-in/mac-sub')
    mul : require('./built-in/mac-mul')
    div : require('./built-in/mac-div')

  defines =
    mac : require('./built-in/mac-mac')
    # quote
    # def
    # int
    # num

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

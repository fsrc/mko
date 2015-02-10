_ = require('lodash')

module.exports = (form, evaluator, defines, macros, scope) ->
  symbol = _(form.children).first()
  args = _(form.children)
    .rest()
    .map((form) -> evaluator(form, scope))
    .value()


  if symbol? and _.has(defines, symbol.str)
    def = defines[symbol.str]
    return def(args...) if def?

  else if symbol? and _.has(macros, symbol.str)
    mac = macros[symbol.str]
    result = mac(args...) if mac?
    return result

  else if symbol? and _.has(scope.mac, symbol.str)
    mac = scope.mac[symbol.str]
    return mac.call(args..., evaluator, defines, macros, scope) if mac?

  form


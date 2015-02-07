_ = require('lodash')

module.exports = (form, evaluator, macros) ->
  symbol = _(form.children).first()
  args = _(form.children)
    .rest()
    .map((form) -> evaluator(form))
    .value()
  mac = macros[symbol.str]
  mac(args...)


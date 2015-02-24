_ = require('lodash')

eval_macro = (arity, block, scope, form) ->
  console.log "Trying to execute macro"

  childscope = _.cloneDeep(scope)
  args       = _.rest(form.children)

  params = _.zipObject(_.map(arity.children, (child) -> child.str), args)

  childscope.symbols = _.assign(params, childscope.symbols)

  _.reduce(block, (subscope, subform) ->
      subscope.evaluator(subscope, subform)
    , childscope)


validate_symbol = (scope, name) -> name
validate_arity  = (scope, arity) -> arity
validate_block  = (scope, block) -> block
validate_number = (scope, number) -> number

sum = (scope, form, fn) ->
  args = _.rest(form.children)
  first = _.first(args)
  scope.last_result = _(args)
    .rest()
    .map((form) -> validate_number(scope, scope.evaluator(scope, form).last_result))
    .reduce(fn, validate_number(scope, scope.evaluator(scope, first).last_result))
  scope

module.exports =
  mac : (scope, form) ->
    name = validate_symbol(scope, form.children[1].str)
    arity = validate_arity(scope, form.children[2])
    block = validate_block(scope, _.drop(form.children, 3))
    console.log "Registering macro", name
    scope.mac[name] = _.partial(eval_macro, arity, block)
    scope

  add : _.partialRight(sum, (acc, value) -> acc + value)
  mul : _.partialRight(sum, (acc, value) -> acc * value)


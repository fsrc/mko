_ = require("lodash")

forms = {}
forms.list = (scope, form) ->
  name = form.children[0].str
  macro = scope.mac[name]
  if not name? or not macro?
    console.log "Form not supported", form
    console.log "With scope", scope.mac
    console.log "Missing symbol" if not name?
    console.log "Name does not exist", name if not macro?
    process.exit(255)
  else
    console.log "Calling macro", name
    macro(scope, form)

forms.string = (scope, form) ->
  scope.last_result = form.str
  scope

forms.int = (scope, form) ->
  scope.last_result = parseInt(form.str)
  scope

forms.num = (scope, form) ->
  scope.last_result = parseFloat(form.str)
  scope

forms.bool = (scope, form) ->
  scope.last_result = form.value
  scope

forms.symbol = (scope, form) ->
  derived_form = scope.symbols[form.str]

  if not derived_form?
    console.log "Symbol '#{form.str}' does not exist"
    process.exit(255)

  if not _.has(forms, derived_form.form)
    console.log "Symbol #{derived_form.form} can't be used"
    process.exit(255)
  forms[derived_form.form](scope, derived_form)

module.exports = (scope, form) ->
  console.log "Evaluating form", form.form
  console.log form
  if not _.has(forms, form.form)
    console.log "Could not evaluate form", form.form
    console.log form
    process.exit(255)
  forms[form.form](_.cloneDeep(scope), form)

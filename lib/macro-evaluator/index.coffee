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

forms.int = (scope, form) ->
  scope.last_result = parseInt(form.str)
  scope

module.exports = (scope, form) ->
  console.log "Evaluating form", form.form
  forms[form.form](_.cloneDeep(scope), form)

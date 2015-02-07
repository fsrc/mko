module.exports = (form) ->
  form.value = form.str.replace(/^"|"$/g, '')
  form


exports.camelCase = (str) ->
  str.replace(/(?:_| |\b)(\w)/g, (str, p1) ->
      p1.toUpperCase())

exports.endsWith = (str, suffix) ->
  str.indexOf(suffix, str.length - suffix.length) != -1

exports.test = (type, atom) ->
  type.test(atom.str)


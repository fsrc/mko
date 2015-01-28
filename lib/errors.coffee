errors =
  100 : (startRow, startColumn, endRow, endColumn) ->
    "(100) Unbalanced pairs at #{startRow}:#{startColumn} and #{endRow}:#{endColumn}"
  101 : (endRow, endColumn) ->
    "(101) Unbalanced at #{endRow}:#{endColumn}"

module.exports = (code, args...) ->
  errors[code](args...)

_ = require('lodash')

module.exports = (args...) ->
  result = args[0]
  console.log "In add", args
  result.value = _.reduce(_.rest(args), (res, arg) ->
    res + arg.value
  , _.first(args).value)
  result.str = result.value.toString()
  result


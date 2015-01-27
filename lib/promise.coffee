_ = require('lodash')
camelCase = require('./helpers').camelCase

module.exports = (events) ->
  _.reduce(events, (acc, event) ->
    name = camelCase(event)
    acc[event] = () ->
    acc["on#{name}"] = (handler) ->
      acc[event] = handler
      acc
    acc
  , { events: events })


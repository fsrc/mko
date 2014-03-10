util = require('util')
_    = require 'underscore'


exports.set = (obj, fn) -> fn( _(obj).clone())
exports.assertnull = (obj, msg, fn) ->
  if obj == null then throw msg
  obj

exports.out = (str) -> process.stdout.write(str)
exports.log = (data) -> console.error(data)
exports.inspect = (data) ->
  console.error(util.inspect(data, {colors:true,depth:null}))

_     = require("underscore")
util  = require("util")
chalk = require("chalk")
chalk.enabled = true

_.mixin(

  assertnull : (obj, msg, fn) ->
    if not obj? then throw msg
    obj

  out : (str) ->
    process.stdout.write(str)
    str

  log : (data) ->
    console.error(data)
    data

  inspect : (data, depth) ->
    console.error(util.inspect(data, {colors:true,depth:depth}))
    data

  push : (arr, item) ->
    arr.push(itm)
    arr

  sum : (arr) ->
    _.reduce(arr, (memo, num) ->
      memo + num
    , 0)

  lift : (obj, fn) ->
    fn(_(obj).clone())

  regexpMap : (text, pat, fn) ->
    result = []
    result.push(fn(match)) while match = pat.exec(text)
    result

  lineNr : (lineIndices, position) ->
    indices = _(lineIndices).clone()
    indices.unshift(0)
    indices.sort((a,b) -> a-b)
    for i in [0...indices.length - 1]
      if position >= indices[i] and position < indices[i + 1]
        return i
    return indices.length - 1
)



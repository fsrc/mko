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

  inspectTokens : (tokens) ->
    _(tokens).traverse((t, indent) ->
      indentstr = _([0...indent]).map(() -> " ").join("")
      _(t.color("#{t.line}:#{t.column}
        \t#{t.index}-#{t.ends}(#{t.value.length})
        \t#{t.type}:#{t.grammar}
        \t#{indentstr}#{t.value}")).log()
      t
    )

  traverse: (tokens, fn) ->
    inspect = (tokens, level) ->
      _(tokens).map((token) ->
        fn(token, level)
        inspect(token.children, level + 1) if token.children?
        fn(token.ender, level) if token.ender?)

    inspect(tokens, 0)
    tokens

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

)



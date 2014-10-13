_     = require("underscore")
util  = require("util")
chalk = require("chalk")
chalk.enabled = true

colorfor = (t) ->
  if (t.type == 'delim' and t.grammar == 'end') or (t.type == 'list' and t.grammar == 'start')
    chalk.gray
  else if (t.type == 'atom' and t.grammar == 'call')
    chalk.green
  else if (t.type == 'atom' and t.grammar == 'value')
    chalk.blue
  else
    chalk.white

showable = (t) ->
  if (t.type == 'delim' and t.grammar == 'end') or (t.type == 'list' and t.grammar == 'start')
    true
  else
    true

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
    _("l:c\tlen\ttype:subtype\tvalue").log()
    _(tokens).traverse((t, indent) ->
      indentstr = _([0...indent-1]).map(() -> "  ").join("")
      if showable(t)
        _(colorfor(t)("#{t.line}:#{t.column}
          \t#{t.value.length}
          \t#{t.type ? 'ndef'}:#{t.grammar}
          \t#{indentstr}#{t.value}
          \t#{if t.error? then chalk.red('ERROR: ' + t.error) else ''}")).log()
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

  matrix: (array, width) ->
    _(array).reduce((result, item) ->
      last = _(result).last()
      if last.length == width
        last = []
        result.push(last)
      last.push(item)
      result
    ,[[]]))



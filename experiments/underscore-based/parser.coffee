_ = require("underscore")

tree = (tokens, root, delimiters) ->
  isstart   = (t) -> _(delimiters.starters).contains(t.value)
  isend     = (t) -> _(delimiters.enders).contains(t.value)
  isenderof = (t, e) -> delimiters.enderof[t.value] == e.value
  prev      = (t, col) ->
    index = _(col).indexOf(t)
    if index > 0
      col[index-1]
    else
      null
  next      = (t, col) ->
    index = _(col).indexOf(t)
    if index < col.length - 1
      col[index+1]
    else
      null

  _(tokens).reduce((stack, token) ->
      top = _(stack).last()

      token.prev = prev(token, top.children)
      if isstart(token)
        top.children ?= []
        top.children.push(token)
        stack.push(token)
        token.parent = top

      else if isend(token) and isenderof(top, token)
        top.ender = token
        stack.pop()

      else if isend(token)
        console.log "Parsing error @ #{top.line}:#{top.column} -> #{token.line}:#{token.column}"
        console.log " - Expected #{delimiters.enderof[top.value]}. Got #{token.value}"

      else
        top.children ?= []
        top.children.push(token)
        token.parent = top

      stack
    , [root()])

defaulted = (funs) ->
  (name) ->
    if _(_(funs).keys()).contains(name)
      funs[name]
    else
      (args...) -> funs.default(name, args...)

grammar = defaulted(
  root:
    gram:(t) ->
      t.grammar = "block"
      t

  list:
    gram:(t) ->
      first = _(t.children).first()
      if first.value == 'def'
        t.grammar = 'def'
        t.grammartype = first
        t.children.shift()
        if t.children.length != 2
          console.log "Parsing error @ #{t.line}:#{t.column} -> #{t.ender.line}:#{t.ender.column}"
          console.log " - A def must always have a symbol and a value. Nothing more and nothing less."
      else if first.value == 'mac'
        t.type = 'mac'
        t.grammar = 'block'
        t.grammartype = first
        t.children.shift()
        t.args = t.children.shift()
        if t.args.type != "list"
          console.log "Parsing error @ #{t.args.line}:#{t.args.column} -> #{t.args.ender.line}:#{t.args.ender.column}"
          console.log " - A macro must always have a argument list. Although it can be empty."

      else if first.value == 'fun'
        t.type = 'fun'
        t.grammar = 'block'
        t.grammartype = first
        t.children.shift()
        t.args = t.children.shift()
        if t.args.type != "list"
          console.log "Parsing error @ #{t.args.line}:#{t.args.column} -> #{t.args.ender.line}:#{t.args.ender.column}"
          console.log " - A function must always have a argument list. Although it can be empty."

      else
        t.grammar = "expr"
      t

  array:
    gram:(t) ->
      t.grammar = "value"
  assoc:
    gram:(t) ->
      t.grammar = "value"
  tuple:
    gram:(t) ->
      t.grammar = "value"

  string:
    gram:(t) ->
      t.grammar = "value"

  atom:
    gram:(t) ->
      t.grammar = 'value'
      t

  delim:
    gram:(t) ->
      t.grammar = "nothing"
      t

  default:
    gram:(t) ->
      t.grammar = "unknown"
      t
)

parse = (tokens, bgrammar) ->
  _(tokens).traverse((token, level) ->
    grammar(token.type).gram(token))

_.mixin(tree :tree)
_.mixin(parse:parse)


_ = require("underscore")

tree = (tokens, root, delimiters) ->
  isstart   = (t) -> _(delimiters.starters).contains(t.value)
  isend     = (t) -> _(delimiters.enders).contains(t.value)
  isenderof = (t, e) -> delimiters.enderof[t.value] == e.value
  _(tokens).reduce((stack, token) ->
      top = _(stack).last()
      if isstart(token)
        top.children ?= []
        top.children.push(token)
        stack.push(token)
      else if isend(token) and isenderof(top, token)
        top.ender = token
        stack.pop()
      else if isend(token)
        console.log "Parsing error at line: #{token.line}"
        console.log "Expected #{delimiters.enderof[top.value]}"
        console.log "Got #{token.value}"
      else
        top.children ?= []
        top.children.push(token)

      stack
    , [root()])


parse = (tokens, groups) ->
  _(tokens).traverse((token, level) ->
    if token.type == "list" and token.children.length > 0
      token.children = _.chain(token.children)
        .rest()
        .map((child) -> _(child).extend(grammar:"expr"))
        .unshift(_(_(token.children).first()).extend(grammar:"call"))
        .value()
    else
      _(token).extend(grammar:"atom")
    token
  )

_.mixin(tree:tree)
_.mixin(parse:parse)


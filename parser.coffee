_ = require("underscore")

inspectTokenTree = (tokens) ->
  print = (t, indent) ->
    indentstr = _([0...indent]).map(() -> " ").join("")
    _(t.color("#{t.line}
      \t#{t.index}-#{t.ends}(#{t.value.length})
      \t#{t.type}
      \t#{indentstr}#{t.value}")).log()

  inspect = (tokens, indent) ->
    _(tokens).map((token) ->
      print(token, indent)
      inspect(token.children, indent + 1) if token.children?
      print(token.ender, indent) if token.ender?)

  inspect(tokens, 0)
  tokens

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


parse = (tokens, defines) ->

_.mixin(inspectTokenTree:inspectTokenTree)
_.mixin(tree:tree)
_.mixin(parse:parse)


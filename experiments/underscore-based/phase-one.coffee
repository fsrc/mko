_ = require("underscore")

list =
  car : (lst) ->
    lst[0]
  cdr : (lst) ->
    lst.slice(1)
  map : (lst, fn) ->
    _(lst).map(fn)

macros = (tokens) ->
  _(tokens).traverse((token) ->
    if token.type == "list"
      console.log "a"
  )

_.mixin(macros:macros)

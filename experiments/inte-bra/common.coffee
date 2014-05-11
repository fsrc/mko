util = require('util')
_    = require 'underscore'



_.mixin({
  mapTree : (list, iterator, context) ->
    _(list).map((item) ->
      item = iterator(item)
      if item.def.isStarter
        item.value = _(item.value).mapTree(iterator, context)
      item)
  filterTree : (list, predicate, context) ->
    _(list).filter((item) ->
      res = predicate(item)
      if res and item.def.isStarter
        item.value = _(item.value).filterTree(predicate, context)
      res)
  eachNode : (list, iterator, context) ->
    _(list).each((item) ->
      iterator(item)
      if item.def.isStarter
        _(item.value).eachNode(iterator, context))
  set : (obj, fn) -> fn( _(obj).clone())

  assertnull : (obj, msg, fn) ->
    if not obj? then throw msg
    obj

  out : (str) ->
    process.stdout.write(str)
    str
  log : (data) ->
    console.error(data)
    data
  shallow : (depth, data) ->
    console.error(util.inspect(data, {colors:true,depth:depth}))
    data
  inspect : (data) ->
    console.error(util.inspect(data, {colors:true,depth:null}))
    data
})

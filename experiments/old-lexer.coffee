_ = require 'underscore'
u = require 'util'


exports.lex = (input) ->
  lexemes = ['(',')','{','}','[',']',"'",'"',' ', '\n']
  stringLexemes = ['"', "'"]
  whiteLexemes = [' ', "\n"]
  _.chain(input)
    # Find all symbols and delimiters
    .reduce(
      (tokens, char) ->
        tokens.push(
          if _(lexemes).contains(char) then char
          else if _(lexemes).contains(_(tokens).last()) then char
          else tokens.pop() + char)
        tokens
    , [])
    # Join strings
    .reduce(
      (tokens, token) ->
        tokens.push(
          if _(stringLexemes).contains(token)
            if @delim == null
              @delim = token
              token
            else if @delim == token
              @delim = null
              tokens.pop() + token
          else
            if @delim == null
              token
            else
              tokens.pop() + token
        )
        tokens
    , [], {delim:null})
    # Strip away any tokens that doesn't have any meaning
    .without(whiteLexemes...)
    .map((token) ->
      if _.isFinite(token)
        parseFloat(token)
      else
        token
    )
    .value()

parse = (input) ->
  (buildTree = (tokens, index = 0) ->
    output = []
    while index < tokens.length
      if tokens[index] == "("
        [index, tmp_array] = buildTree(tokens, index + 1)
        output.push(tmp_array)
      else if tokens[index] == ")"
        return [index, output]
      else
        output.push(tokens[index])
      index += 1
    return [index, output])(input)[1]

compilejs = (input) ->
  sanitizeIdentifier = (identifier) ->
    identifier
      .replace("+", "__PLUS__")
      .replace("-", "__MINUS__")
      .replace("?", "__QUESTION__")

  evalExp = (exp) ->

  if _(input).isString()
    sanitizeIdentifier(input)
  else if _(input).isNumber()
    input
  else
    _(input).map((exp) ->
      if(exp[0] == "def")
        "var #{sanitizeIdentifier(exp[1])} = #{evalExp(exp[2])};"

      else if (exp[0] == "mac")
        # compile and insert macro into internal list

      else if (exp[0] == "fun")
        "var #{exp[1]} = function(#{exp[2].join(',')}){}"

      else if (exp[0] == "if")
        "if(#{evalExp(exp[1])}) {#{evalExp(exp[2])}} else {#{evalExp(exp[3])}}"

  )

evaljs = (input) ->
  sanid = (identifier) ->
    if not _(identifier).isString()
      throw "Token '#{identifier}' is not a valid identifier"
    identifier
      .replace("+", "__PLUS__")
      .replace("-", "__MINUS__")
      .replace("?", "__QUESTION__")

  if _(input).isNumber()
    input
  else if _(input).isString()
    input
  else if _(input).isArray()
    _(input).map((lst) ->
      if not _(lst).isArray()
        console.log "!!!! #{lst}"
        lst
      else
        # The prefix, used to determine what to do
        pref = lst.shift()

        # Directly calling an anonymous function
        if _(pref).isArray()
          fun = evaljs([pref])
          args = _(lst).map((arg) ->
            if _(arg).isArray()
              evaljs([arg])
            else if _(arg).isString()
              sanid(arg)
            else if _(arg).isNumber()
              arg)
          "(#{fun})(#{args.join(',')});"

        # Declaring a variable
        else if pref == "def"
          identifier = sanid(lst[0])
          expr = if _(lst[1]).isArray()
            evaljs([lst[1]])
          else
            evaljs(lst[1])
          "var #{identifier}=#{expr};\n"

        # Defining a function
        else if pref == "fun"
          args = _(lst.shift()).map(sanid).join(",")
          body = evaljs(lst).join(";\n")
          "function(#{args}) {\n#{body};\n}"

        # Defining a macro
        else if pref == "mac"
          "mac"

        # If-macro implementation
        else if pref == "if"
          condExpr = evaljs([lst[0]])
          altaExpr = evaljs(lst[1])
          altbExpr = evaljs(lst[2])
          """(function() {
              var ___RESULT = null;
              if(#{condExpr}) {
                ___RESULT = #{altaExpr};
              } else {
                ___RESULT = #{altbExpr};
              }
              return ___RESULT;
          })()"""

        # Any other function or macro call
        else
          args = _(lst).map((arg) ->
            if _(arg).isArray()
              evaljs([arg])
            else if _(arg).isString()
              sanid(arg)
            else if _(arg).isNumber()
              arg)
          "#{sanid(pref)}(#{args.join(',')})"
    )

if require.main == module
  #source = """
  #(def lasse 8)
  #(def lisa 9)
  #(def lasse+lisa (add lasse gurkan))
  #(def calc (fun (a b)
    #(add a b)
    #(sub b a)))
  #(def j (if (eq x y) a b))
  #(read-file file-name (fun (err result)
    #(console.log "Error output:")
    #(console.log err)
    #(console.log "Result output:")
    #(console.log result)))
  #(def move (fun (x y)
    #(doer x y)))
  #(move 4 5)
  #((fun (x y)
    #(digg x y))
    #3 4)
  #"""

  #source = """
  #(console.log (say "Error output:"))
  #"""
  #source = """
  #(console.log "Error output:")
  #"""
  source = "(a b)(c d)(1 3)"

  tokens = exports.lex(source)
  #console.log("Lexed result")
  #console.log(u.inspect(tokens, depth:null, colors:false))

  ast = parse(tokens)
  #console.log("Parsed result")
  #console.log(u.inspect(ast, depth:null, colors:false))

  js = evaljs(ast).join(';\n')
  console.log(js)


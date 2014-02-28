
compile = (ast) ->
  sanid = (identifier) ->
    if not _(identifier).isString()
      throw "Token '#{identifier}' is not a valid identifier"
    identifier
      .replace("+", "__PLUS__")
      .replace("-", "__MINUS__")
      .replace("?", "__QUESTION__")

  ast

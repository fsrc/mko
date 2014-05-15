_      = require('underscore')
chalk  = require("chalk")
common = require('./common')

_.mixin(
  coordinate : (lineIndices, position) ->
    indices = _(lineIndices).clone()
    indices.unshift(0)
    indices.sort((a,b) -> a-b)
    for line in [0...indices.length - 1]
      if position >= indices[line] and position < indices[line + 1]
        column = position - indices[line]
        return { line:line + 1, column:column }
    return { line: "unknown", column: "unknown"}
)
# The tokenizer
# Input:
#   text: The text to tokenize
#   defines: A associative array with keys:
#     patterns
tokenize = (text, defines) ->

  # Removes any matches that falls within deadSpaces
  rejectOverlaps = (matches, deadSpaces) ->
    _(matches).filter((match) ->
      not _(deadSpaces).some((space) ->
        match.index >= space.index and match.index < space.ends))

  # Later on we use this to decorate our tokens with line numbers
  newLines = _(text).regexpMap(/\n/mg, (match) -> match.index)

  # We start out with iterating rules
  _.chain(defines.patterns)

    # Create an array of matches for each rule
    .map((pat, type) ->
      _(text).regexpMap(new RegExp(pat.rex, "mg"), (match) ->
        value = match.shift()
        index = match.index
        subtype = pat.subtype(value) if pat.subtype?

        color : pat.color
        type  : type
        value : value
        index : index
        ends  : index + value.length))

    # Remove the top level array, joining all matches
    .flatten()

    # Apply precedents rules by first grouping by rule type
    .groupBy('type')
    .lift((matches) ->
      _(matches).map((matchesOfType, typeName) ->
        rejectOverlaps(matchesOfType , _.chain(matches)
          .pick(defines.patterns[typeName].precedents)
          .values()
          .flatten()
          .value())))

    # Out comes arrays of arrays, so we flatten them
    .flatten()

    # Apply subtypes
    .map((token) ->
      if defines.patterns[token.type].subtype?
        token.type =
          defines.patterns[token.type].subtype(token.value)
      token)

    # Decorate tokens with line numbers and columns
    .map((token) -> _(token).extend(_(newLines).coordinate(token.index)))

    # Make sure all tokens appear in the correct order
    .sortBy((token) -> token.index)
    .value()

_.mixin(tokenize:tokenize)


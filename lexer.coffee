_      = require('underscore')
chalk  = require("chalk")

common = require('./common')

_.mixin(
  inspectTokens: (tokens) ->
    _(tokens).map((token) ->
      _(token.color("#{token.line}
        \t#{token.index}-#{token.ends}(#{token.value.length})
        \t#{token.type}
        \t#{token.value}")).log()))

# Removes any matches that falls within deadSpaces
rejectOverlaps = (matches, deadSpaces) ->
  _(matches).filter((match) ->
    not _(deadSpaces).some((space) ->
      match.index >= space.index and match.index < space.ends))

# The tokenizer
# Input:
#   defines: A associative array with keys:
#     newlinepattern
#     patterns
#   text: The text to tokenize
tokenize = (defines, text) ->
  # Later on we use this to decorate our tokens with line numbers
  newLines = _(text).regexpMap(defines.newlinepattern, (match) -> match.index)

  # We start out with iterating rules
  _.chain(defines.patterns)

    # Create an array of matches for each rule
    .map((pat, type) ->
      _(text).regexpMap(new RegExp(pat.rex, "mg"), (match) ->
        value = match.shift()
        index = match.index
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

    # Decorate tokens with line numbers
    .map((token) -> _(token).extend(line:_(newLines).lineNr(token.index) + 1))

    # Make sure all tokens appear in the correct order
    .sortBy((token) -> token.index)

# Export tokenize function if file is required
if require.main != module
  module.exports = tokenize

# Make a test run if file is run by it self
else
  fs      = require("fs")
  defines = require('./defines')
  #
  # Read a sample file
  fs.readFile("test.lisp", encoding:'utf8', (err, text) ->
    console.log(chalk.red("Start"))

    tokenize(defines, text).inspectTokens()

    console.log(chalk.red("Done"))
    )

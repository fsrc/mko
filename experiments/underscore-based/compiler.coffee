_        = require("underscore")
chalk    = require("chalk")
tokenize = require("./lexer")
parse    = require("./parser")


if require.main != module
else
  # Make a test run if file is run by it self
  fs      = require("fs")
  defines = require('./defines')

  # Read a sample file
  fs.readFile("test.lisp", encoding:'utf8', (err, text) ->

    console.log(chalk.red("Start"))
    console.log(text)

    _.chain(text)
      .tokenize(defines)
      .inspectTokens()
      .tree(defines.root, defines.delimiters)
      .inspectTokens()
      .parse(defines.grammar)
      .inspectTokens()
      .validate()

    console.log(chalk.red("Done")))


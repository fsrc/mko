_        = require("underscore")
chalk    = require("chalk")
tokenize = require("./lexer")
parse    = require("./parser")


if require.main != module

# Make a test run if file is run by it self
else
  fs      = require("fs")
  defines = require('./defines')
  #
  # Read a sample file
  fs.readFile("test.lisp", encoding:'utf8', (err, text) ->
    console.log(chalk.red("Start"))

    _.chain(text)
      .tokenize(defines)
      .tree(defines.root, defines.delimiters)
      .inspectTokenTree()

    console.log(chalk.red("Done")))

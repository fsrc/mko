_ = require("lodash")
rules = require("../rules")
test = require("../helpers").test
char = require("./char-emitter")
atom = require("./atom-emitter")


module.exports = (strm) ->
  atom(rules, char(rules, strm))

_ = require("lodash")

rules = require("../rules")
char = require("./char-emitter")
atom = require("./atom-emitter")
enclosing = require("./enclosing-emitter")
filter = require("./filter-emitter")
forms = require("./form-emitter")
tree = require("./tree-emitter")


module.exports = _.compose(
    _.partialRight(tree, rules)
    _.partial(forms, rules)
    _.partialRight(filter, 'linefeed', 'comment', 'space')
    _.partialRight(enclosing, 'comment', 'linefeed')
    _.partialRight(enclosing, 'string', 'string')
    _.partial(atom, rules)
    _.partial(char, rules))

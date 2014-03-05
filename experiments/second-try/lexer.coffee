util = require 'util'
_    = require 'underscore'
k    = require './common'

# Defines

LPAREN    = '('
RPAREN    = ')'
LBRACE    = '{'
COLON     = ':'
RBRACE    = '}'
LTHAN     = '<'
GTHAN     = '>'
LBRACK    = '['
RBRACK    = ']'
SLASH     = '/'
PIPE      = '|'
SQUOTE    = "'"
DQUOTE    = '"'
SPACE     = ' '
NEWLINE   = '\n'
TAB       = '\t'
SEMICOLON = ";"

SLIST      = "start_list"
ELIST      = "end_list"
SASOC      = "start_assoc_array"
DASOC      = "delimit_assoc_array"
EASOC      = "end_assoc_array"
SARR       = "start_array"
EARR       = "end_array"
REGEX      = "regex"
STUP       = "start_tuple"
ETUP       = "end_tuple"
QUOTE      = "quote"
STRING     = "string"
COMMENT    = "comment"
WHITESPACE = "whitespace"
EOL        = "end_of_line"

LIST = 'list'
ARR = 'array'
ASOC = 'asoc'
TUP = 'tuple'

LISTSEMAP =
    start   : SLIST
    end     : ELIST
    type    : LIST
ASOCSEMAP =
    start   : SASOC
    end     : EASOC
    type    : ASOC
ARRSEMAP  =
    start   : SARR
    end     : EARR
    type    : ARR
TUPSEMAP  =
    start   : STUP
    end     : ETUP
    type    : TUP

SEMAPS = {}
SEMAPS[SLIST]=LISTSEMAP
SEMAPS[ELIST]=LISTSEMAP
SEMAPS[SASOC]=ASOCSEMAP
SEMAPS[EASOC]=ASOCSEMAP
SEMAPS[SARR]=ARRSEMAP
SEMAPS[EARR]=ARRSEMAP
SEMAPS[STUP]=TUPSEMAP
SEMAPS[ETUP]=TUPSEMAP

ALL_LGROUP = [
  LPAREN,
  RPAREN,
  LBRACE,
  COLON,
  RBRACE,
  LBRACK,
  RBRACK,
  LTHAN,
  GTHAN,
  SLASH,
  PIPE,
  SQUOTE,
  DQUOTE,
  SPACE,
  NEWLINE,
  TAB,
  SEMICOLON]

LEX_AFFINITY = {}
LEX_AFFINITY[LPAREN]    = SLIST
LEX_AFFINITY[RPAREN]    = ELIST
LEX_AFFINITY[LBRACE]    = SASOC
LEX_AFFINITY[COLON]     = DASOC
LEX_AFFINITY[RBRACE]    = EASOC
LEX_AFFINITY[LBRACK]    = SARR
LEX_AFFINITY[RBRACK]    = EARR
LEX_AFFINITY[SLASH]     = REGEX
LEX_AFFINITY[LTHAN]     = STUP
LEX_AFFINITY[GTHAN]     = ETUP
LEX_AFFINITY[SQUOTE]    = QUOTE
LEX_AFFINITY[DQUOTE]    = STRING
LEX_AFFINITY[SPACE]     = WHITESPACE
LEX_AFFINITY[NEWLINE]   = EOL
LEX_AFFINITY[TAB]       = WHITESPACE
LEX_AFFINITY[SEMICOLON] = COMMENT

STRING_LGROUP     = [DQUOTE]
DELIM_LGROUP      = [SPACE, NEWLINE, TAB]
COMMENT_LGROUP    = [SEMICOLON, NEWLINE]
WHITESPACE_LGROUP = [SPACE,TAB]
LIST_LGROUP       = [LPAREN,RPAREN]
ASOC_LGROUP       = [LBRACE,RBRACE,COLON]
ARR_LGROUP        = [LBRACK,RBRACK]
TUP_LGROUP        = [LTHAN,GTHAN]
REGEX_LGROUP      = [SLASH]

nlex = (char, row, col) ->
  token:char
  row:row
  col:col
  len:1
jlex = (a, b) ->
  k.set(a, (n) ->
    n.token += b.token
    n.len += b.len
    n)
ilex = (a, char) ->
  k.set(a, (n) ->
    n.token += char
    n.len += 1
    n)

lex = (input) ->
  _.chain(input)
    # Find all symbols and delimiters
    .reduce(
      (lexemes, char) ->
        lexemes.push(
          if _(ALL_LGROUP).contains(char) then nlex(char, @row, @col)
          else if _(ALL_LGROUP).contains(_(lexemes).last().token) then nlex(char, @row, @col)
          else ilex(lexemes.pop(), char))
        @col += 1
        if char == NEWLINE
          @col = 1
          @row += 1
        lexemes
    , [],{row:1,col:1})
    # Join strings
    .reduce(
      (lexemes, lexeme) ->
        lexemes.push(
          # Handle one or more whitespaces
          if _(WHITESPACE_LGROUP).contains(lexeme.token)
            if @delim == null
              @delim = lexeme.token
              k.assertnull(k.set(lexeme, (l) -> l.type="whitespace";l), "@delim=#{@delim}, #{util.inspect(lexeme)}")
            else
              k.assertnull(jlex(lexemes.pop(), lexeme), "@delim=#{@delim}, #{util.inspect(lexeme)}")

          # All other cases
          else
            # Reset @delim if it was set to a white space group delimiter
            @delim = null if _(WHITESPACE_LGROUP).contains(@delim)

            atest = (group,token,delim) ->
              _(group).contains(token) and (delim == null or _(group).contains(delim))
            first = () ->
              k.assertnull(k.set(lexeme, (l) -> l.type=LEX_AFFINITY[l.token];l), "@delim=#{@delim}, #{util.inspect(lexeme)}")
            join = () ->
              k.assertnull(jlex(lexemes.pop(), lexeme), "@delim=#{@delim}, #{util.inspect(lexeme)}")

            # Handle strings
            if atest(STRING_LGROUP,lexeme.token,@delim)
              if @delim == null
                @delim = lexeme.token
                first()
              else if @delim == lexeme.token
                @delim = null
                join()

            # Handle comments
            else if atest(COMMENT_LGROUP,lexeme.token,@delim)
              if @delim == null and lexeme.token == SEMICOLON
                @delim = lexeme.token
              else if @delim != null and lexeme.token == NEWLINE
                @delim = null
              first()

            # Trailing end of a regex
            else if @delim == SLASH+SLASH
              @delim = null
              join()
            else if atest(REGEX_LGROUP,lexeme.token,@delim)
              if @delim == null and lexeme.token == SLASH
                @delim = lexeme.token
                first()
              else if @delim == lexeme.token == SLASH
                @delim = SLASH+SLASH
                join()

            # Handle all other cases
            else
              if @delim == null
                first()
              else
                join())
        lexemes
    , [], {delim:null})
    # Convert any numbers to number type
    .map((lexeme) ->
      if lexeme.type?
        lexeme
      else
        if _.isFinite(lexeme.token)
          k.set(lexeme, (prev) ->
            prev.type = "number"
            prev.token = parseFloat(lexeme.token)
            prev)
        else
          lexeme.type = "identifier"
          lexeme
    )
    .compact()
    .value()

nocomments = (input) ->
  _(input).chain()
    .reject((lex) -> lex.type == COMMENT)
    .reject((lex) ->
      if lex.type == EOL
        if @remove
          doremove = true
        @remove = true
      else
        @remove = false
      doremove?
    , { remove: false })
    .value()

nowhitespace = (input) ->
  _(input).chain()
    .reject((lex) -> lex.type == WHITESPACE)
    .reject((lex) -> lex.type == EOL)
    .value()

restruct = (token_array) ->
  restructure = (token_array, offset = 0, expect) ->
    buildasoc = (struct) ->
      asoc = []
      for i in [0..struct.length-1] by 3
        ident = _(struct[i]).clone()
        ident.value = _(struct[i+2]).clone()
        asoc.push(ident)
      asoc

    struct = []
    while offset < token_array.length
      tokentype = token_array[offset].type

      if _([SLIST,SARR,SASOC,STUP]).contains(tokentype)
        [offset, tmp_array] = restructure(token_array, offset + 1, SEMAPS[tokentype].end)
        struct.push({type:SEMAPS[tokentype].type, value:tmp_array})

      else if _([ELIST,EARR,EASOC,ETUP]).contains(tokentype)
        if tokentype == expect
          if tokentype == EASOC
            struct = buildasoc(struct)
          break
        else
          k.log("Parsing error at line #{token_array[offset].row} column #{token_array[offset].col}: Expected '#{expect}' got '#{tokentype}'")
          process.kill()
      else
        struct.push(token_array[offset])
      offset += 1
    return [offset, struct]
  restructure(token_array, 0, null).pop()


if not module.parent?
  fs   = require('fs')
  filename = process.argv[2]

  if not filename?
    k.log("You must provide a file to be lexed")
  else
    k.log("Reading file '#{filename}'")
    fs.readFile(filename, encoding:'utf8', (err, raw) ->
      k.log("Lexing..")
      lexed = nowhitespace(nocomments(lex(raw)))
      k.inspect(lexed)
      ast = restruct(lexed)
      #k.inspect(ast)
      fs.writeFile("#{filename}.lex", JSON.stringify(ast), {encoding:'utf8'}, (err) ->
        if err?
          k.log "Could not write file!"
          k.err err
        else
          k.log "Lex file written (#{filename}.lex)"
      ))


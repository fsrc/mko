require('coffee-script').register();
var compile  = require('./lib/compiler');
var fs       = require('fs');

fname = process.argv[2];
console.log("Input file: " + fname);
strm = fs.createReadStream(fname, {
  flags:'r',
  encoding:'utf8',
  autoClose:true});

compile(strm)

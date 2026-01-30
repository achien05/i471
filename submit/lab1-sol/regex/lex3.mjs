// Note JavaScript allow specifying regex literals within /.../ delimiters
export default {
  $Ignore: /\s+|\/\/.*/,  // \s matches whitespace; \s+ matches one-or-more whitespace
                   // $Ignore means that any whitespace will be ignored.
  ID: /[_a-zA-Z][_a-zA-Z0-9]*/, //using [] to denote an _ or alphabetical first character followed by "one-or-more alphanumeric characters or underscores _" (lab1 instructions)
  INT: /\d+/,      // \d matches a digit, \d+ matches one-or-more digits for
                   // token with kind INT        
  CHAR: /./,       // single char: must be last;
                   // . is a regex which matches any char other than '\n'
};

package test;

import parsihax.Parsihax.*;
using parsihax.Parsihax;

enum LispExpression {
  LispNumber(v: Int);
  LispSymbol(v: String);
  LispList(v : Array<LispExpression>);
}

class LispTest {
  public static function parse(text : String) {
    // A little helper to wrap a parser with optional whitespace.
    function spaced(parser) {
      return optWhitespace().then(parser).skip(optWhitespace());
    }

    // We need to use `P.ref` here because the other parsers don't exist yet. We
    // can't just declare this later though, because `LList` references this parser!
    var LExpression = ref();

    // The basic parsers (usually the ones described via regexp) should have a
    // description for error message purposes.
    var LSymbol =
      ~/[a-zA-Z_-][a-zA-Z0-9_-]*/.regexp()
      .map(function(r) return LispSymbol(r))
      .desc('symbol');

    var LNumber =
      ~/[0-9]+/.regexp()
      .map(function (result) return LispNumber(Std.parseInt(result)))
      .desc('number');

    // `.then` throws away the first value, and `.skip` throws away the second
    // `.value, so we're left with just the `spaced(LExpression).many()` part as the
    // `.yielded value from this parser.
    var LList =
      '('.string()
      .then(spaced(LExpression).many())
      .skip(')'.string())
      .map(function(r) return LispList(r));

    LExpression.set(function() {
      return [
        LSymbol,
        LNumber,
        LList
      ].alt();
    }.lazy());

    // Let's remember to throw away whitespace at the top level of the parser.
    var lisp = spaced(LExpression);

    return lisp.parse(text);
  }
}
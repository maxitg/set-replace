Package["SetReplace`"]

PackageExport["Description"]
PackageExport["MultipliedHalf"]

(* String <-> Expression *)

declareMultihistoryTranslation[stringToExpression, "String", "Expression"];
stringToExpression[Multihistory["String", str_]] := Multihistory["Expression", ToExpression[str]];

declareMultihistoryTranslation[expressionToString, "Expression", "String"];
expressionToString[Multihistory["Expression", expr_]] := Multihistory["String", ToString[expr]];

(* EvenInteger <-> HalfInteger *)

(** Translations **)

declareMessage[General::notAnInteger, "The number `number` in `expr` is expected to be an integer."];
declareMultihistoryTranslation[halfToEvenInteger, "HalfInteger", "EvenInteger"];
halfToEvenInteger[Multihistory["HalfInteger", n_Integer]] := Multihistory["EvenInteger", 2 * n];
halfToEvenInteger[Multihistory["HalfInteger", n_]] := throw[Failure["notAnInteger", <|"number" -> n|>]];

declareMessage[General::notEven, "The number `number` in `expr` should be even."];
declareMultihistoryTranslation[evenToHalfInteger, "EvenInteger", "HalfInteger"];
evenToHalfInteger[Multihistory["EvenInteger", n_ ? EvenQ]] := Multihistory["HalfInteger", n / 2];
evenToHalfInteger[Multihistory["EvenInteger", n_]] := throw[Failure["notEven", <|"number" -> n|>]];

(** Properties **)

declareRawMultihistoryProperty[evenIntegerDescription, "EvenInteger", Description];
evenIntegerDescription[][Multihistory[_, n_]] := "I am an integer `n`.";

declareRawMultihistoryProperty[multipliedNumber, "HalfInteger", MultipliedHalf];
multipliedNumber[factor_][Multihistory[_, n_]] := factor * n;

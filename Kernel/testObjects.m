Package["SetReplace`"]

(* String <-> Expression *)

declareMultihistoryTranslation[stringToExpression, "String", "Expression"];
stringToExpression[Multihistory["String", str_]] := Multihistory["Expression", ToExpression[str]];

declareMultihistoryTranslation[expressionToString, "Expression", "String"];
expressionToString[Multihistory["Expression", expr_]] := Multihistory["String", ToString[expr]];

(* Odd <-> Even *)

declareMessage[General::wrongParity, "The number `number` in `expr` is not `oddOrEven`."];

declareMultihistoryTranslation[oddToEven, "Odd", "Even"];
oddToEven[Multihistory["Odd", n_ ? OddQ]] := Multihistory["Even", n + 1];
oddToEven[Multihistory["Odd", n_]] := throw[Failure["wrongParity", <|"number" -> n, "oddOrEven" -> "odd"|>]];

declareMultihistoryTranslation[evenToOdd, "Even", "Odd"];
evenToOdd[Multihistory["Even", n_ ? EvenQ]] := Multihistory["Odd", n - 1];
evenToOdd[Multihistory["Even", n_]] := throw[Failure["wrongParity", <|"number" -> n, "oddOrEven" -> "even"|>]];

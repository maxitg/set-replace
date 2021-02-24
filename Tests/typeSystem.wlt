<|
  "typeSystem" -> <|
    "init" -> (
      Attributes[Global`testUnevaluated] = Attributes[Global`testSymbolLeak] = {HoldAll};
      Global`testUnevaluated[args___] := SetReplace`PackageScope`testUnevaluated[VerificationTest, args];
      Global`testSymbolLeak[args___] := SetReplace`PackageScope`testSymbolLeak[VerificationTest, args];
      Global`objectType = SetReplace`PackageScope`objectType;
      Global`declareTypeTranslation = SetReplace`PackageScope`declareTypeTranslation;
      Global`declareMessage = SetReplace`PackageScope`declareMessage;
      Global`declareRawMethod = SetReplace`PackageScope`declareRawMethod;
      Global`initializeTypeSystem = SetReplace`PackageScope`initializeTypeSystem;
      Global`throw = SetReplace`PackageScope`throw;
      Global`throwInvalidMethodArgumentCount = SetReplace`PackageScope`throwInvalidMethodArgumentCount;

      (* UnknownObject *)

      objectType[obj_unknownObject] := "Unknown";

      (* String <-> Expression *)

      objectType[string_String] := "String";
      objectType[expr_expression] := "Expression";

      declareTypeTranslation[stringToExpression, "String", "Expression"];
      stringToExpression[str_] := expression[ToExpression[str]];

      declareTypeTranslation[expressionToString, "Expression", "String"];
      expressionToString[expression[expr_]] := ToString[expr];

      (* EvenInteger <-> HalfInteger *)

      objectType[halfInteger_halfInteger] := "HalfInteger";
      objectType[integer_evenInteger] := "EvenInteger";

      (** Translations **)

      declareMessage[General::notAnInteger, "The number `number` in `expr` is expected to be an integer."];
      declareTypeTranslation[halfToEvenInteger, "HalfInteger", "EvenInteger"];
      halfToEvenInteger[halfInteger[n_Integer]] := evenInteger[2 * n];
      halfToEvenInteger[halfInteger[n_]] := throw[Failure["notAnInteger", <|"number" -> n|>]];

      declareMessage[General::notEven, "The number `number` in `expr` should be even."];
      declareTypeTranslation[evenToHalfInteger, "EvenInteger", "HalfInteger"];
      evenToHalfInteger[evenInteger[n_ ? EvenQ]] := halfInteger[n / 2];
      evenToHalfInteger[evenInteger[n_]] := throw[Failure["notEven", <|"number" -> n|>]];

      (** Methods **)

      (*** Description ***)

      declareRawMethod[evenIntegerDescription, "EvenInteger", description];

      evenIntegerDescription[][evenInteger[n_]] := "I am an integer " <> ToString[n] <> ".";

      evenIntegerDescription[args__][_] := throwInvalidMethodArgumentCount[0, Length[{args}]];

      (*** MultipliedHalf ***)

      declareRawMethod[multipliedNumber, "HalfInteger", multipliedHalf];

      multipliedNumber[factor_Integer][halfInteger[n_]] := factor * n;

      declareMessage[General::nonIntegerFactor, "The factor `factor` in `expr` must be an integer."];
      multipliedNumber[factor : Except[_Integer]][_] := throw[Failure["nonIntegerFactor", <|"factor" -> factor|>]];

      multipliedNumber[args___][_] /; Length[{args}] != 1 := throwInvalidMethodArgumentCount[1, Length[{args}]];

      initializeTypeSystem[];
    ),
    "tests" -> {
      (* Translations *)
      VerificationTest[
        SetReplaceTypeConvert["Expression"] @ SetReplaceTypeConvert["String"] @ expression[4], expression[4]],
      VerificationTest[SetReplaceTypeConvert["HalfInteger"] @ evenInteger[4], halfInteger[2]],
      VerificationTest[SetReplaceTypeConvert["HalfInteger"] @ halfInteger[3], halfInteger[3]],
      VerificationTest[SetReplaceTypeConvert["EvenInteger"] @ halfInteger[3], evenInteger[6]],

      testUnevaluated[SetReplaceTypeConvert["Expression"] @ unknownObject[5], SetReplaceTypeConvert::unconvertibleType],
      testUnevaluated[SetReplaceTypeConvert["Unknown"] @ expression[4], SetReplaceTypeConvert::unconvertibleType],
      testUnevaluated[SetReplaceTypeConvert["Expression"] @ halfInteger[3], SetReplaceTypeConvert::noConversionPath],
      testUnevaluated[SetReplaceTypeConvert["HalfInteger"] @ evenInteger[3], SetReplaceTypeConvert::notEven],
      testUnevaluated[SetReplaceTypeConvert["EvenInteger"] @ halfInteger[a], SetReplaceTypeConvert::notAnInteger],

      (* Raw Methods *)
      VerificationTest[multipliedHalf[5] @ halfInteger[3], 15],
      VerificationTest[multipliedHalf[5] @ evenInteger[4], 10],
      VerificationTest[multipliedHalf[halfInteger[3], 4], 12],
      VerificationTest[multipliedHalf[evenInteger[4], 4], 8],
      VerificationTest[description @ evenInteger[4], "I am an integer 4."],
      VerificationTest[description @ halfInteger[4], "I am an integer 8."],
      VerificationTest[description[] @ halfInteger[4], "I am an integer 8."], (* Operator form with no arguments *)

      testUnevaluated[multipliedHalf[] @ halfInteger[3], multipliedHalf::invalidMethodArgumentCount],
      testUnevaluated[multipliedHalf[1, 2, 3] @ halfInteger[3], multipliedHalf::invalidMethodArgumentCount],
      testUnevaluated[multipliedHalf @ halfInteger[3], multipliedHalf::invalidMethodArgumentCount],
      testUnevaluated[multipliedHalf[halfInteger[3], 4, 5], multipliedHalf::invalidMethodArgumentCount],
      testUnevaluated[description[1] @ halfInteger[4], description::invalidMethodArgumentCount],
      testUnevaluated[description[halfInteger[3], 3], description::invalidMethodArgumentCount],

      testUnevaluated[multipliedHalf[4, 4, 5][], multipliedHalf::invalidMethodOperatorArgument],
      testUnevaluated[multipliedHalf[4, 4, 5][halfInteger[4], 2, 3], multipliedHalf::invalidMethodOperatorArgument],
      testUnevaluated[description[][], description::invalidMethodOperatorArgument],

      testUnevaluated[multipliedHalf[4] @ cookie, multipliedHalf::unknownObject],
      testUnevaluated[multipliedHalf[4, 4, 5] @ cookie, multipliedHalf::unknownObject],
      testUnevaluated[description[] @ cookie, description::unknownObject],
      testUnevaluated[multipliedHalf[5] @ expression[3], multipliedHalf::noMethodPath],
      testUnevaluated[multipliedHalf[5] @ evenInteger[3], multipliedHalf::notEven],
      testUnevaluated[multipliedHalf[evenInteger[3], 4], multipliedHalf::notEven],
      testUnevaluated[multipliedHalf[x] @ halfInteger[3], multipliedHalf::nonIntegerFactor],
      testUnevaluated[multipliedHalf @ cookie, {}], (* should not throw a message because it might be an operator *)
      testUnevaluated[description @ cookie, {}]
    }
  |>
|>

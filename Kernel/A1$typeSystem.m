Package["SetReplace`"]

PackageImport["GeneralUtilities`"]

PackageExport["SetReplaceTypeConvert"]

PackageScope["declareTypeTranslation"]
PackageScope["declareRawMethod"]
PackageScope["declareCompositeMethod"]
PackageScope["objectType"]
PackageScope["throwInvalidMethodArgumentCount"]

PackageScope["initializeTypeSystem"]

declareMessage[General::unknownObject, "The argument `arg` in `expr` is not a known typed object."];

(* Object classes (like Multihistory) are expected to define their own objectType[...] implementation. This one is
   triggered if no other is found. *)

objectType[arg_] := throw[Failure["unknownObject", <|"arg" -> arg|>]];

objectQ[object_] := Catch[objectType[object]; True, _ ? FailureQ, False &];

(* No declaration is required for a generator to create a new object type. Its job is to create a consistent internal
   structure. *)

(* The following functions collect the declarations for type conversions and methods. They are not processed
   immediately. Instead, there is a separate function to process them (and define all relevant DownValues), which is
   called from init.m. Note that as a result this file should load before the files with any declarations. *)

(* Some types can be convertable from one another. To convert an object from one type to another, one can use a
   declareTypeTranslation function. *)

(* Type translation functions can throw failure objects, in which case a message will be generated with a name
   corresponding to the Failure's type, and the keys passed to the message template. *)

$translations = {};

declareTypeTranslation[function_, fromType_, toType_] :=
  AppendTo[$translations, {function, type[fromType], type[toType]}];

(* This function is called after all declarations to combine translations to a Graph to allow multi-step conversions. *)

initializeTypeSystemTranslations[] := (
  $typeGraph = Graph[DirectedEdge @@@ Rest /@ $translations];
  $translationFunctions = Association[Thread[EdgeList[$typeGraph] -> (First /@ $translations)]];

  (* Find all strings used in the type names even on deeper levels (e.g., {"HypergraphSubstitutionSystem", 3}). *)
  With[{typeStrings = Cases[VertexList[$typeGraph], _String, All]},
    If[Length[typeStrings] > 0,
      FE`Evaluate[FEPrivate`AddSpecialArgCompletion["SetReplaceTypeConvert" -> {typeStrings}]]
    ];
  ];
);

(* SetReplaceTypeConvert is a public plumbing function that allows one to convert objects from one type to another for
   optimization or persistence. *)

SetUsage @ "
SetReplaceTypeConvert[type$][object$] converts an object$ to the requested type$.
";

SyntaxInformation[SetReplaceTypeConvert] = {"ArgumentsPattern" -> {type_}};

expr : SetReplaceTypeConvert[args1___][args2___] := ModuleScope[
  result = Catch[setReplaceTypeConvert[args1][args2],
                 _ ? FailureQ,
                 message[SetReplaceTypeConvert, #, <|"expr" -> HoldForm[expr]|>] &];
  result /; !FailureQ[result]
];

declareMessage[General::unconvertibleType, "The type `type` in `expr` can not be used for type conversions."];

declareMessage[General::noConversionPath, "Cannot convert an object from `from` to `to` in `expr`."];

setReplaceTypeConvert[toType_][object_] := ModuleScope[
  fromType = objectType[object];
  If[!VertexQ[$typeGraph, type[#]], throw[Failure["unconvertibleType", <|"type" -> #|>]]] & /@ {fromType, toType};
  path = FindShortestPath[$typeGraph, type[fromType], type[toType]];
  If[path === {} && toType =!= fromType,
    throw[Failure["noConversionPath", <|"from" -> fromType, "to" -> toType|>]];
  ];
  edges = DirectedEdge @@@ Partition[path, 2, 1];
  functions = $translationFunctions /@ edges;
  Fold[#2[#1] &, object, functions]
];

(* declareRawMethod declares an implementation for a method for a particular object type. If requested for another type,
   an attempt will be made to convert to a type for which an implementation is available. *)

(* Implementation has the form: implementationFunction[args___][object_] where object is always of the requested type.
   toMethod will need to be called as toMethod[args___][object_] or toMethod[object_, args___] where object can be of
   any type convertable to the implemented one. *)

$rawMethods = {};

declareRawMethod[implementationFunction_, fromType_, toMethod_Symbol] :=
  AppendTo[$rawMethods, {implementationFunction, type[fromType], method[toMethod]}];

(* This function is called after all declarations to combine implementations to a Graph to allow multi-step conversions
   and to define DownValues for all method symbols. *)

initializeRawMethods[] := Module[{newEdges},
  newEdges = DirectedEdge @@@ Rest /@ $rawMethods;
  $typeGraph = EdgeAdd[$typeGraph, newEdges];
  $methodEvaluationFunctions = Association[Thread[newEdges -> (First /@ $rawMethods)]];

  defineDownValuesForMethod /@ Cases[VertexList[$typeGraph], method[name_] :> name, {1}];
];

(* declareCompositeMethod declares an implementation for a method that takes other methods as arguments. The relevant
   methods will be given to implementationFunction as functions. *)

(* Implementation has the form: implementationFunction[args___][methodFunction$1_, methodFunction$2_, ...] where
   methodFunction$i should be called as methodFunction$i[args], i.e., without an object argument. Correct object will
   be used automatically. *)

(* toMethod will be possible to use the same way as in declareRawMethod and will work as long as all requested methods
   are implemented with either approach. *)

declareCompositeMethod[implementationFunction_, fromMethods_List, toMethod_Symbol] := ModuleScope[
  Null; (* TODO: implement *)
];

(* This function is called after all declarations to combine implementations to a Graph to allow multi-step conversions
   and to define DownValues for all method symbols. *)

initializeCompositeMethods[] := (
  Null; (* TODO: implement *)
);

(* This function is called in init.m after all other files are loaded. *)

initializeTypeSystem[] := (
  initializeTypeSystemTranslations[];
  initializeRawMethods[];
  initializeCompositeMethods[];
);

(* defineDownValuesForMethod defines both the operator form and the normal form for a method symbol. The DownValues it
   defines first search for the best path to compute a method and then evaluate the corresponding method
   implementation/translation functions. *)

declareMessage[General::noMethodPath, "Cannot compute the method `method` for type `type` in `expr`."];

(* invalidMethodArgumentCount message is not thrown here, but is defined here because it needs to be intercepted in case
   a method is used not as an operator form (in which case expected and actual argument counts should be incremented by
   one). *)

declareMessage[
  General::invalidMethodArgumentCount,
  "`expectedCount` argument`expectedCountPluralWordEnding` expected in `expr` instead of given `actualCount`."];

throwInvalidMethodArgumentCount[expectedCount_, actualCount_] :=
  throw[Failure["invalidMethodArgumentCount", <|"expectedCount" -> expectedCount,
                                                "expectedCountPluralWordEnding" -> If[expectedCount == 1, "", "s"],
                                                "actualCount" -> actualCount|>]];

incrementArgumentCounts[Failure[name : "invalidMethodArgumentCount", args_]] :=
  Failure[name, ReplacePart[args, {"expectedCount" -> args["expectedCount"] + 1,
                                   "actualCount" -> args["actualCount"] + 1,
                                   "expectedCountPluralWordEnding" -> If[args["expectedCount"] == 0, "", "s"]}]];

incrementArgumentCounts[arg_] := arg;

(* Note that it's not possible to have another object as a first argument to the method, i.e.,
   method[auxiliaryObject][mainObjectArgument], because in that case it's impossible to distinguish for which object
   the method should be evaluated. *)

declareMessage[General::invalidMethodOperatorArgument,
               "A single object argument is expected to the operator form `expr`."];

Attributes[defineDownValuesForMethod] = {HoldFirst};
defineDownValuesForMethod[publicMethod_] := (
  expr : publicMethod[args___][object___] := ModuleScope[
    result = Catch[methodImplementation[publicMethod][args][object],
                   _ ? FailureQ,
                   message[publicMethod, #, <|"expr" -> HoldForm[expr], "head" -> publicMethod|>] &];
    result /; !FailureQ[result]
  ];

  expr : publicMethod[object_ ? objectQ, args___] := ModuleScope[
    result = Catch[methodImplementation[publicMethod][args][object],
                   _ ? FailureQ,
                   message[publicMethod,
                           incrementArgumentCounts[#],
                           <|"expr" -> HoldForm[expr], "head" -> publicMethod|>] &];
    result /; !FailureQ[result]
  ];

  methodImplementation[publicMethod][args___][object_] := ModuleScope[
    fromType = objectType[object];
    If[!VertexQ[$typeGraph, type[fromType]], throw[Failure["unknownType", <|"type" -> fromType|>]]];
    path = FindShortestPath[$typeGraph, type[fromType], method[publicMethod]];
    If[path === {},
      throw[Failure["noMethodPath", <|"type" -> fromType, "method" -> publicMethod|>]];
    ];
    expectedTypeObject = setReplaceTypeConvert[path[[-2, 1]]][object];
    methodFunction = $methodEvaluationFunctions[DirectedEdge[path[[-2]], path[[-1]]]];
    methodFunction[args][expectedTypeObject]
  ];

  methodImplementation[publicMethod][args1___][args2___] := throw[Failure["invalidMethodOperatorArgument", <||>]];
);

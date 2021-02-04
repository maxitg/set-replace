Package["SetReplace`"]

PackageImport["GeneralUtilities`"]

PackageExport["Multihistory"]
PackageExport["MultihistoryConvert"]

PackageScope["declareMultihistoryTranslation"]
PackageScope["declareRawMultihistoryProperty"]
PackageScope["declareCompositeMultihistoryProperty"]

PackageScope["multihistoryType"]

PackageScope["initializeMultihistory"]

SetUsage @ "
Multihistory[$$] is an object containing evaluation of a non-deterministic computational system.
";

SyntaxInformation[Multihistory] = {"ArgumentsPattern" -> {type_, internalData_}};

(* Multihistory can contain an evaluation of any system, such as set/hypergraph substitution, string substitution, etc.
   Internally, it has a type specifying what kind of system it is as the first argument, and any data as the second.
   Generators can create multihistories of any type of their choosing. Properties can take any type as an input.
   This file contains functions that automate conversion between types.
   Note that specific types should never appear in this file, as Multihistory infrastructure is not type specific. *)

multihistoryType[Multihistory[type_, _]] := type;

declareMessage[General::notMultihistory, "The argument `arg` in `expr` is not a multihistory."];

multihistoryType[multihistory_] := throw[Failure["notMultihistory", <|"arg" -> multihistory|>]];

(* No declaration is required for a generator to create a new Multihistory type. Its job is to create a consistent
   internal structure. *)

(* The following functions collect the declarations for type conversions and properties. They are not processed
   immediately. Instead, there is a separate function to process them (and define all relevant DownValues), which is
   called from init.m.
   Note that as a result this file should load before the files with any declarations. *)

(* Some types can be convertable from one another. To convert one multihistory type to another, one can use a
   declareMultihistoryTranslation function. *)

(* Multihistory translation functions can throw failure objects, in which case a message will be generated with a name
   corresponding to the Failure's type, and the keys passed to the message template. *)

$translations = {};

declareMultihistoryTranslation[function_, fromType_, toType_] := AppendTo[$translations, {function, fromType, toType}];

(* This function is called after all declarations to combine translations to a Graph to allow multi-step conversions. *)

initializeMultihistoryTranslations[] := (
  $typesGraph = Graph[DirectedEdge @@@ Rest /@ $translations];
  $translationFunctions = Association[Thread[EdgeList[$typesGraph] -> (First /@ $translations)]];

  (* Find all strings used in the type names even on deeper levels (e.g., {"HypergraphSubstitutionSystem", 3}). *)
  With[{typeStrings = Cases[VertexList[$typesGraph], _String, All]},
    FE`Evaluate[FEPrivate`AddSpecialArgCompletion["MultihistoryConvert" -> {typeStrings}]]
  ];
);

(* MultihistoryConvert is a public plumbing function that allows one to convert multihistories from one type to another
   for optimization or persistence. *)

SetUsage @ "
MultihistoryConvert[type$][multihistory$] converts a multihistory$ to the requested type$.
";

SyntaxInformation[MultihistoryConvert] = {"ArgumentsPattern" -> {type_}};

expr : MultihistoryConvert[args1___][args2___] := ModuleScope[
  result = Catch[
    multihistoryConvert[args1][args2], _ ? FailureQ, message[MultihistoryConvert, #, <|"expr" -> HoldForm[expr]|>] &];
  result /; !FailureQ[result]
];

declareMessage[General::unknownType,
               "The type `type` `fromOrTo` which conversion is required in `expr` is not recognized."];

declareMessage[General::noConversionPath, "Cannot convert a Multihistory from `from` to `to` in `expr`."];

multihistoryConvert[toType_][multihistory_] := ModuleScope[
  fromType = multihistoryType[multihistory];
  If[!VertexQ[$typesGraph, #1], throw[Failure["unknownType", <|"fromOrTo" -> #2, "type" -> #1|>]]] & @@@
    {{fromType, "from"}, {toType, "to"}};
  path = FindShortestPath[$typesGraph, fromType, toType];
  If[path === {} && toType =!= fromType,
    throw[Failure["noConversionPath", <|"from" -> fromType, "to" -> toType|>]];
  ];
  edges = DirectedEdge @@@ Partition[path, 2, 1];
  functions = $translationFunctions /@ edges;
  Fold[#2[#1] &, multihistory, functions]
];

(* declareRawMultihistoryProperty declares an implementation for a property for a particular Multihistory type.
   If requested for another type, an attempt will be made to convert to a type for which an implementation is
   available. *)

(* Implementation has the form: implementationFunction[args___][multihistory_] where multihistory is always of the
   requested type.
   
   propertySymbol will need to be called as propertySymbol[args___][multihistory_] where multihistory can be of any
   type convertable to the implemented one. *)

declareRawMultihistoryProperty[propertySymbol_Symbol, implementationFunction_, type_] := ModuleScope[
  Null; (* TODO: implement *)
]

(* declareMultihistoryPropertyFromOtherProperties declares an implementation for a property that takes other properties
   as arguments. The relevant properties will be given to implementationFunction as functions. *)

(* Implementation has the form: implementationFunction[args___][propertyFunction$1_, propertyFunction$2_, ...] where
   propertyFunction$i should be called as propertyFunction$i[args], i.e., without a Multihistory argument. Correct
   multihistory will be used automatically.

   propertySymbol will be possible to use the same way as in declareRawMultihistoryProperty and will work as long as
   all requested properties are implemented with either approach. *)

declareCompositeMultihistoryProperty[propertySymbol_Symbol, implementationFunction_, properties_List] := ModuleScope[
  Null; (* TODO: implement *)
]

(* This function is called after all declarations to combine implementations to a Graph to allow multi-step conversions
   and to define DownValues for all property symbols. *)

initializeMultihistoryProperties[] := (
  Null; (* TODO: implement *)
)

(* This function is called in init.m after all other files are loaded. *)

initializeMultihistory[] := (
  initializeMultihistoryTranslations[];
  initializeMultihistoryProperties[];
);

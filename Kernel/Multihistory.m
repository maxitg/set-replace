Package["SetReplace`"]

PackageImport["GeneralUtilities`"]

PackageExport["Multihistory"]
PackageExport["MultihistoryConvert"]

PackageScope["declareMultihistoryTranslation"]
PackageScope["declareMultihistoryProperty"]
PackageScope["declareMultihistoryPropertyImplementation"]
PackageScope["multihistoryArgument"]
PackageScope["multihistoryPropertyListArgument"]

PackageScope["multihistoryType"]

PackageScope["initializeMultihistory"]

SetUsage @ "
Multihistory[$$] is an object containing an evaluation of a non-deterministic computational system.
";

SyntaxInformation[Multihistory] = {"ArgumentsPattern" -> {type_, data_}};

(* Multihistory can contain an evaluation of any system, such as set/hypergraph substitution, string substitution, etc.
   Internally, it has a type specifying what kind of system it is as a first argument, and any data as the second.
   Generators can create multihistories of any type of their choosing. Properties can take any type as an input.
   This file contains functions that automate conversion between types.
   Note that specific types should never appear in this file, as Multihistory infrastructure is not type specific. *)

multihistoryType[Multihistory[type_, _]] := type;

General::notMultihistory = "The argument `1` is not a multihistory.";

multihistoryType[multihistory_] := (
  Message[$currentHead::notMultihistory, multihistory];
  Throw[$Failed];
);

(* No declaration is required for a generator to create a new Multihistory type. Its job is to create a consistent
   internal structure. *)

(* The following functions collect the declarations for type conversions and properties. They are not processed
   immediately. Instead, there is a separate function to process them (and define all relevant DownValues), which is
   called from init.m.
   Note that as a result this file should load before the files with any declarations. *)

(* Some types can be convertable from one another. To convert one multihistory type to another, one can use a
   declareMultihistoryTranslation function. *)

$translations = {};

declareMultihistoryTranslation[function_, fromType_, toType_] := ModuleScope[
  AppendTo[$translations, {function, fromType, toType}];
];

(* This function is called in init.m to combine translations to a Graph to allow multi-step conversions. *)

initializeMultihistoryTranslations[] := (
  $typesGraph = Graph[DirectedEdge @@@ Rest /@ $translations];
  $translationFunctions = Thread[EdgeList[$typesGraph] -> (First /@ $translations)];
);

(* MultihistoryConvert is a public plumbing function that allows one to convert multihistories from one type to another
   for optimization or persistence reasons. *)

MultihistoryConvert[args1___][args2___] := Scope[
  $currentHead = MultihistoryConvert;
  res = Catch[multihistoryConvert[args1][args2]];
  res /; res =!= $Failed
];

multihistoryConvert[toType_][multihistory_] := ModuleScope[
  fromType = multihistoryType[multihistory];
  path = FindShortestPath[$typesGraph, fromType, toType];
  edges = DirectedEdge @@@ Partition[path, 2, 1];
  functions = $translationFunctions /@ edges;
  Fold[#2[#1] &, multihistory, functions]
];

(* declareMultihistoryProperty declares a new property, but does not provide any implementations for it. It is used to
   specify the symbol for the property and its syntax information. Once declared, properties can be called as
   propertySymbol[args][multihistory]. *)

(* Syntax information in the second argument can include keywords such as "GenerationCount" that would be automatically
   checks for validity. *)

(* TODO: This should put the property to a $properties variable. *)

$properties = {};

declareMultihistoryProperty[propertySymbol_, syntaxInformation_] := ModuleScope[
  Throw["Not implemented."];
];

(* declareMultihistoryPropertyImplementation declares an implementation for a property. Implementations are specific to
   a particular Multihistory type. Instead of a type, however, one can ask for any type that implements a particular set
   of properties with an implementsProperties[{...}] symbol as the third argument. *)

(* TODISCUSS: Note that it's possible that there is no object that implements all the requested properties directly,
              however there is an object that can be converted to objects that implement each property.
              I guess in that case we don't need to convert it, but we need to check that an object we are returning
              implements all requested properties in some way. *)

(* IDEA: perhaps we should have two versions of declareMultihistoryPropertyImplementation.
         One of them takes a type as and argument and promises to pass that and only that type to the implementation
         function.
         The other one would take a list of properties, and it will pass *functions* implementing those properties
         instead of the object. The benefit for doing this is that it will be impossible for implementation functions
         to start incorrectly relying on getting a specific type as an argument and doing illegal operations with it. *)

(* STATUS: Need to design the properties first to determine if we need both types of the syntax. *)

(* TODO: Add these to $propertyImplementations Association. *)

declareMultihistoryPropertyImplementation[propertySymbol_,
                                          implementationFunction_,
                                          multihistoryArgument[type_]] := ModuleScope[
  Throw["Not implemented."];
];

declareMultihistoryPropertyImplementation[propertySymbol_,
                                          implementationFunction_,
                                          multihistoryPropertyListArgument[properties_List]] := ModuleScope[
  Throw["Not implemented."];
  (* propFunc2 = (Property2[#][multihistory] &); *)
];

initializeMultihistory[] := (
  initializeMultihistoryTranslations[];
);

(* Usage examples:

tokenCount[args___][obj_] := ...

tokenCount[generation_][tokenList_, propFunc2_] := ModuleScope[
  allTokens = tokenList[generation];
  Length[allTokens]
]

tokenList[All][multihistory]

*)

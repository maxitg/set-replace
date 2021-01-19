Package["SetReplace`"]

PackageImport["GeneralUtilities`"]

PackageExport["Multihistory"]
PackageExport["MultihistoryConvert"]

PackageScope["declareMultihistoryTranslation"]
PackageScope["declareMultihistoryProperty"]
PackageScope["declareMultihistoryPropertyImplementation"]
PackageScope["multihistoryType"]
PackageScope["multihistoryPropertyList"]

SetUsage @ "
Multihistory[$$] is an object containing an evaluation of a non-deterministic computational system.
";

SyntaxInformation[Multihistory] = {"ArgumentsPattern" -> {___}};

(* Multihistory can contain an evaluation of any system, such as set/hypergraph substitution, string substitution, etc.
   Internally, it's an association with a "Type" key that specifies what kind of system it is.
   Generators can create multihistories of any type of their choosing. Properties can take any type as an input.
   This file contains function that automate conversion between types.
   Note that specific types should never appear in this file, as Multihistory infrastructure is not type specific. *)

(* TODISCUSS: Should multihistories always be Associations with a "Type" key, or would it be better to require
   Generations to implement a multihistoryType function for the types they generate? If we do the latter, we can allow
   Multihistories to have arbitrary heads and structure. *)

(* No declaration is required for a generator to create a new Multihistory type. Its job is to create a consistent
   internal structure. *)

(* TODISCUSS: Should we collect all declarations first and then do postprocessing? Or should we keep consistent state
              after every new declaration (could be slower). *)

(* Note that this file should load before the files with any declarations. *)

(* Some types can be convertable from one another. To convert one multihistory type to another, one can use a
   declareMultihistoryTranslation function. *)

$translations = {};

declareMultihistoryTranslation[function_, fromType_, toType_] := ModuleScope[
  AppendTo[$translations, {fromType, toType, function}];
];

(* MultihistoryConvert is a public plumbing function that allows one to convert multihistories from one type to another
   for optimization or persistence reasons. *)

MultihistoryConvert[toType_][multihistory_] := ModuleScope[
  Throw["Not implemented."];
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

(* TODO: Add these to $propertyImplementations Association. *)

declareMultihistoryPropertyImplementation[propertySymbol_,
                                          implementationFunction_,
                                          multihistoryType[type_]] := ModuleScope[
  Throw["Not implemented."];
];

declareMultihistoryPropertyImplementation[propertySymbol_,
                                          implementationFunction_,
                                          multihistoryPropertyList[properties_List]] := ModuleScope[
  Throw["Not implemented."];
];

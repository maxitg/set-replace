Package["SetReplace`"]

PackageImport["GeneralUtilities`"]

PackageExport["GenerateMultihistory"]
PackageExport["GenerateAllHistories"]
PackageExport["GenerateFullEventSet"]
PackageExport["GenerateSingleHistory"]
PackageExport["$SetReplaceSystems"]
PackageExport["EventSelectionParameters"]
PackageExport["EventOrderingFunctions"]
PackageExport["StoppingConditionParameters"]

PackageScope["generateMultihistory"]

PackageScope["declareMultihistoryGenerator"]
PackageScope["initializeGenerators"]

$usageSetReplaceSystems = "* A list of all supported systems can be obtained with $SetReplaceSystems.";
$usageEventOrderingSpec =
"* eventOrderingSpec$ can be set to 'UniformRandom', 'Any', or a list of partial event ordering functions. The list of \
supported functions can be obtained with EventOrderingFunctions[Head[system$]].";

SetUsage[Evaluate["
GenerateMultihistory[system$, eventSelectionSpec$, tokenDeduplicationSpec$, eventOrderingSpec$, \
stoppingConditionSpec$][init$] yields a Multihistory object of the evaluation of a specified system$.
" <> $usageSetReplaceSystems <> "
* eventSelectionSpec$ is an Association defining constraints on the events that will be generated. The keys that can \
be used depend on the system$, some examples include 'MaxGeneration' and 'MaxDestroyerEvents'. A list for a particular \
system can be obtained with EventSelectionParameters[Head[system$]].
* tokenDeduplicationSpec$ can be set to None or All.
" <> $usageEventOrderingSpec <> "
* stoppingConditionSpec$ is an Association specifying conditions (e.g., 'MaxEvents') that, if satisfied, will cause \
the evaluation to stop immediately. The list of choices can be obtained with StoppingConditionParameters[Head[system$]].
"]];

SyntaxInformation[GenerateMultihistory] = {"ArgumentsPattern" ->
  {system_, eventSelectionSpec_, tokenDeduplicationSpec_, eventOrderingSpec_, stoppingConditionSpec_}};

SetUsage[Evaluate["
GenerateAllHistories[system$, maxGeneration$][init$] yields a Multihistory object representing all possible histories \
of the evaluation of a specified system$ up to maxGeneration$.
" <> $usageSetReplaceSystems <> "
"]];

SyntaxInformation[GenerateAllHistories] = {"ArgumentsPattern" -> {system_, maxGeneration_}};

SetUsage[Evaluate["
GenerateFullEventSet[system$, maxGeneration$][init$] yields a complete event set (Petri net) object enumerating all
events that can occur within maxGenerations$ starting from init$ tokens.
" <> $usageSetReplaceSystems <> "
"]];

SyntaxInformation[GenerateFullEventSet] = {"ArgumentsPattern" -> {system_, maxGeneration_}};

SetUsage[Evaluate["
GenerateSingleHistory[system$, eventOrderingSpec$, eventCount$][init$] yields a Multihistory object containing \
eventCount$ events of an evaluation of a single history of the specified system$ using eventOrderingSpec$.
" <> $usageSetReplaceSystems <> "
" <> $usageEventOrderingSpec <> "
"]];

SyntaxInformation[GenerateSingleHistory] = {"ArgumentsPattern" -> {system_, eventOrderingSpec_, eventCount_}};

(* Declaration *)

$implementations = CreateDataStructure["HashTable"];
$eventSelectionSpecs = CreateDataStructure["HashTable"];    (* generator -> <|key -> {default, constraint}, ...|> *)
$eventOrderings = CreateDataStructure["HashTable"];         (* generator -> {ordering, ...} *)
$stoppingConditionSpecs = CreateDataStructure["HashTable"]; (* generator -> <|key -> {default, constraint}, ...|> *)

$possibleConstraints = None | "NonNegativeIntegerOrInfinity";

$constraintsSpecPattern =
  _Association ? (AllTrue[StringQ] @ Keys[#] && MatchQ[Values[#], {{_, $possibleConstraints}...}] &);

(* Every generator needs to call this function in order to be usable through GenerateMultihistory and related functions.
   The metadata about selection, ordering and stopping conditions will be used to automatically check the arguments.
   The implementation function can expect event selection and stopping conditions to be passed as associations with
   all specified keys present and valid according to the constraint (substituted with defaults if missing).
   Event ordering will be passed as a list of strings from the eventOrderings argument. *)

(* For example,
   declareMultihistoryGenerator[
     generateMultisetSubstitutionSystem,
     MultisetSubstitutionSystem,
     <|"MaxGeneration" -> {Infinity, "NonNegativeIntegerOrInfinity"},
       "MinEventInputs" -> {0, "NonNegativeIntegerOrInfinity"}|>,
     {"InputCount", "SortedInputTokenIndices", "InputTokenIndices", "RuleIndex", "InstantiationIndex"},
     <|"MaxEvents" -> {Infinity, "NonNegativeIntegerOrInfinity"}|>] *)

declareMultihistoryGenerator[implementationFunction_,
                             systemType_,
                             eventSelectionSpec : $constraintsSpecPattern,
                             eventOrderings : {___String},
                             stoppingConditionSpec : $constraintsSpecPattern] := (
  $implementations["Insert", systemType -> implementationFunction];
  $eventSelectionSpecs["Insert", systemType -> eventSelectionSpec];
  $eventOrderings["Insert", systemType -> eventOrderings];
  $stoppingConditionSpecs["Insert", systemType -> stoppingConditionSpec];
);

declareMessage[General::invalidGeneratorDeclaration,
               "Internal error. Multihistory generator is declared incorrectly with arguments `args`."];
declareMultihistoryGenerator[args___] :=
  message[SetReplace, Failure["invalidGeneratorDeclaration", <|"args" -> {args}|>]];

(* GenerateMultihistory *)

expr : (generator : GenerateMultihistory[args___])[init___] /;
    CheckArguments[generator, 5] && CheckArguments[expr, 1] := ModuleScope[
  result = Catch[generateMultihistory[args, init],
                 _ ? FailureQ,
                 message[GenerateMultihistory, #, <|"expr" -> HoldForm[expr]|>] &];
  result /; !FailureQ[result]
];

generateMultihistory[system_ /; $implementations["KeyExistsQ", Head[system]],
                     rawEventSelection_,
                     rawTokenDeduplication_,
                     rawEventOrdering_,
                     rawStoppingCondition_,
                     init_] := ModuleScope[
  $implementations["Lookup", Head[system]][
    system,
    parseConstraints["invalidEventSelection"][$eventSelectionSpecs["Lookup", Head[system]]][rawEventSelection],
    parseTokenDeduplication[rawTokenDeduplication],
    parseEventOrdering[$eventOrderings["Lookup", Head[system]]][rawEventOrdering],
    parseConstraints["invalidStoppingCondition"][$stoppingConditionSpecs["Lookup", Head[system]]][rawStoppingCondition],
    init
  ]
];

declareMessage[General::unknownSystem, "System `system` in `expr` is not recognized."];
generateMultihistory[system_, __] := throw[Failure["unknownSystem", <|"system" -> system|>]];

(* GenerateAllHistories *)

expr : (generator : GenerateAllHistories[args___])[init___] /;
    CheckArguments[generator, 2] && CheckArguments[expr, 1] := ModuleScope[
  result = Catch[generateAllHistories[args, init],
                 _ ? FailureQ,
                 message[GenerateAllHistories, #, <|"expr" -> HoldForm[expr]|>] &];
  result /; !FailureQ[result]
];

generateAllHistories[system_ /; $implementations["KeyExistsQ", Head[system]], maxGeneration_, init_] := ModuleScope[
  $implementations["Lookup", Head[system]][
    system,
    parseMaxGeneration[maxGeneration, system],
    None,
    "Any",
    parseConstraints["invalidStoppingCondition"][$stoppingConditionSpecs["Lookup", Head[system]]][{}],
    init]
];

parseMaxGeneration[maxGeneration_, system_] := parseConstraints["invalidEventSelection"][
  $eventSelectionSpecs["Lookup", Head[system]]]["MaxGeneration" -> maxGeneration];

generateAllHistories[system_, __] := throw[Failure["unknownSystem", <|"system" -> system|>]];

(* GenerateFullEventSet *)

expr : (generator : GenerateFullEventSet[args___])[init___] /;
    CheckArguments[generator, 2] && CheckArguments[expr, 1] := ModuleScope[
  result = Catch[generateFullEventSet[args, init],
                 _ ? FailureQ,
                 message[GenerateFullEventSet, #, <|"expr" -> HoldForm[expr]|>] &];
  result /; !FailureQ[result]
];

generateFullEventSet[system_ /; $implementations["KeyExistsQ", Head[system]], maxGeneration_, init_] := ModuleScope[
  $implementations["Lookup", Head[system]][
    system,
    parseMaxGeneration[maxGeneration, system],
    "EventSet",
    "Any",
    parseConstraints["invalidStoppingCondition"][$stoppingConditionSpecs["Lookup", Head[system]]][{}],
    init]
];

generateFullEventSet[system_, __] := throw[Failure["unknownSystem", <|"system" -> system|>]];

(* GenerateSingleHistory *)

expr : (generator : GenerateSingleHistory[args___])[init___] /;
    CheckArguments[generator, 3] && CheckArguments[expr, 1] := ModuleScope[
  result = Catch[generateSingleHistory[args, init],
                 _ ? FailureQ,
                 message[GenerateSingleHistory, #, <|"expr" -> HoldForm[expr]|>] &];
  result /; !FailureQ[result]
];

generateSingleHistory[
    system_ /; $implementations["KeyExistsQ", Head[system]], rawEventOrdering_, maxEvents_, init_] := ModuleScope[
  $implementations["Lookup", Head[system]][
    system,
    parseConstraints["invalidEventSelection"][$eventSelectionSpecs["Lookup", Head[system]]][
      {"MaxDestroyerEvents" -> 1}],
    None,
    parseEventOrdering[$eventOrderings["Lookup", Head[system]]][rawEventOrdering],
    parseMaxEvents[maxEvents, system],
    init]
];

parseMaxEvents[maxEvents_, system_] := parseConstraints["invalidStoppingCondition"][
  $stoppingConditionSpecs["Lookup", Head[system]]]["MaxEvents" -> maxEvents];

generateSingleHistory[system_, __] := throw[Failure["unknownSystem", <|"system" -> system|>]];

(* Parsing *)
(* In addition to associations, lists of rules and single rules are allowed. *)

parseConstraints[errorName_][specs_][listOfRules : {___Rule}] :=
  parseConstraints[errorName][specs][listOfRules, Association[listOfRules]];
parseConstraints[errorName_][specs_][rule_Rule] := parseConstraints[errorName][specs][rule, Association[rule]];
parseConstraints[errorName_][specs_][associationOrInvalid_] :=
  parseConstraints[errorName][specs][associationOrInvalid, associationOrInvalid];
parseConstraints[_][specs_][_, argument_Association] /; SubsetQ[Keys[specs], Keys[argument]] :=
  Association @ KeyValueMap[#1 -> checkParameter[#1, #2[[2]]] @ Lookup[argument, #1, #2[[1]]] &, specs];
declareMessage[General::invalidEventSelection,
               "Event selection spec `argument` in `expr` should be an Association with keys from `choices`."];
declareMessage[General::invalidStoppingCondition,
               "Stopping condition spec `argument` in `expr` should be an Association with keys from `choices`."];
parseConstraints[errorName_][specs_][originalArgument_, _] :=
  throw[Failure[errorName, <|"argument" -> originalArgument, "choices" -> Keys[specs]|>]];

$tokenDeduplicationValues = {None, All};
parseTokenDeduplication[value : Alternatives @@ $tokenDeduplicationValues] := value;
declareMessage[
  General::invalidTokenDeduplication, "Token deduplication `value` in `expr` can only be one of `choices`."];
parseTokenDeduplication[value_] :=
  throw[Failure["invalidTokenDeduplication", <|"value" -> value, "choices" -> $tokenDeduplicationValues|>]];

parseEventOrdering[supportedFunctions_][argument_List] /; SubsetQ[supportedFunctions, argument] := argument;
parseEventOrdering[_][argument : "Any"] := argument;
declareMessage[
  General::invalidEventOrdering, "Event ordering spec `argument` in `expr` should be a List of values from `choices`."];
parseEventOrdering[supportedFunctions_][argument_] :=
  throw[Failure["invalidEventOrdering", <|"argument" -> argument, "choices" -> supportedFunctions|>]];

checkParameter[_, None][value_] := value;
checkParameter[_, "NonNegativeIntegerOrInfinity"][value : (_Integer ? (# >= 0 &)) | Infinity] := value;
declareMessage[General::notNonNegativeIntegerOrInfinityParameter,
               "Parameter `name` in `expr` is expected to be a non-negative integer or Infinity."];
checkParameter[name_, "NonNegativeIntegerOrInfinity"][_] :=
  throw[Failure["notNonNegativeIntegerOrInfinityParameter", <|"name" -> name|>]];

(* Initialization *)

(* It would be best to only show autocompletions for specific-system keys, but it does not seem to be possible because
   dependent argument completions are only supported in WL if the main argument is a string. *)

constraintArgumentCompletions[hashTable_] := Replace[Union @ Catenate[Keys /@ hashTable["Values"]], {} -> 0];

SetUsage @ "
$SetReplaceSystems gives the list of all computational systems that can be used with GenerateMultihistory and related \
functions.
";

initializeGenerators[] := (
  $SetReplaceSystems = Sort @ $implementations["Keys"];
  With[{
      selectionKeys = constraintArgumentCompletions[$eventSelectionSpecs],
      orderings = Replace[Union @ Catenate @ $eventOrderings["Values"], {} -> 0],
      stoppingConditionKeys = constraintArgumentCompletions[$stoppingConditionSpecs]},
    FE`Evaluate[FEPrivate`AddSpecialArgCompletion[
      "GenerateMultihistory" -> {0, selectionKeys, 0, orderings, stoppingConditionKeys, 0}]];
  ];
);

(* Introspection functions *)

SetUsage @ "
EventSelectionParameters[system$] yields the list of event selection parameters that can be used with system$.
";

SyntaxInformation[EventSelectionParameters] = {"ArgumentsPattern" -> {system_}};

expr : EventSelectionParameters[args___] /; CheckArguments[expr, 1] := ModuleScope[
  result = Catch[eventSelectionParameters[args],
                 _ ? FailureQ,
                 message[EventSelectionParameters, #, <|"expr" -> HoldForm[expr]|>] &];
  result /; !FailureQ[result]
];

eventSelectionParameters[system_Symbol | system_Symbol[___]] /; $eventSelectionSpecs["KeyExistsQ", system] :=
  Keys @ $eventSelectionSpecs["Lookup", system];

eventSelectionParameters[system_] := throw[Failure["unknownSystem", <|"system" -> system|>]];

SetUsage @ "
EventOrderingFunctions[system$] yields the list of event ordering functions that can be used with system$.
";

SyntaxInformation[EventOrderingFunctions] = {"ArgumentsPattern" -> {system_}};

expr : EventOrderingFunctions[args___] /; CheckArguments[expr, 1] := ModuleScope[
  result = Catch[eventOrderingFunctions[args],
                 _ ? FailureQ,
                 message[EventOrderingFunctions, #, <|"expr" -> HoldForm[expr]|>] &];
  result /; !FailureQ[result]
];

eventOrderingFunctions[system_Symbol | system_Symbol[___]] /; $eventOrderings["KeyExistsQ", system] :=
  $eventOrderings["Lookup", system];

eventOrderingFunctions[system_] := throw[Failure["unknownSystem", <|"system" -> system|>]];

SetUsage @ "
StoppingConditionParameters[system$] yields the list of stopping condition parameters that can be used with system$.
";

SyntaxInformation[StoppingConditionParameters] = {"ArgumentsPattern" -> {system_}};

expr : StoppingConditionParameters[args___] /; CheckArguments[expr, 1] := ModuleScope[
  result = Catch[stoppingConditionParameters[args],
                 _ ? FailureQ,
                 message[StoppingConditionParameters, #, <|"expr" -> HoldForm[expr]|>] &];
  result /; !FailureQ[result]
];

stoppingConditionParameters[system_Symbol | system_Symbol[___]] /; $stoppingConditionSpecs["KeyExistsQ", system] :=
  Keys @ $stoppingConditionSpecs["Lookup", system];

stoppingConditionParameters[system_] := throw[Failure["unknownSystem", <|"system" -> system|>]];

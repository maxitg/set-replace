Package["SetReplace`"]

PackageImport["GeneralUtilities`"]

PackageExport["MultisetSubstitutionSystem"]

SetUsage @ "
MultisetSubstitutionSystem[{pattern$1, pattern$2, $$} :> output$] is a rewriting system that replaces subsets with \
elements matching pattern$1, pattern$2, $$ by a list produced by evaluating output$, where pattern$i can be matched in \
any order.
MultisetSubstitutionSystem should be used as the first argument in functions such as GenerateMultihistory.
";

SyntaxInformation[MultisetSubstitutionSystem] = {"ArgumentsPattern" -> {rules_}};

declareMultihistoryGenerator[
  generateMultisetSubstitutionSystem,
  MultisetSubstitutionSystem,
  <|"MaxGeneration" -> {Infinity, "NonNegativeIntegerOrInfinity"},
    "MaxDestroyerEvents" -> {Infinity, "NonNegativeIntegerOrInfinity"},
    "MinEventInputs" -> {0, "NonNegativeIntegerOrInfinity"},
    "MaxEventInputs" -> {Infinity, "NonNegativeIntegerOrInfinity"}|>,
  {"InputCount", "SortedInputTokenIndices", "InputTokenIndices", "RuleIndex", "InstantiationIndex"},
  <|"MaxEvents" -> {Infinity, "NonNegativeIntegerOrInfinity"}|>];

generateMultisetSubstitutionSystem[MultisetSubstitutionSystem[rawRules___],
                                   rawEventSelection_,
                                   rawTokenDeduplication_,
                                   rawEventOrdering_,
                                   rawStoppingCondition_,
                                   rawInit_] := Block[{
    expressions, eventRuleIndices, eventInputs, eventOutputs, eventGenerations, expressionCreatorEvents,
    expressionDestroyerEventCounts, destroyerChoices, instantiationCounts, instantiations},
  Module[{rules, maxGeneration, maxDestroyerEvents, minEventInputs, maxEventInputs, maxEvents, init, terminationReason},
    rules = parseRules[rawRules];
    {maxGeneration, maxDestroyerEvents, minEventInputs, maxEventInputs} = Values @ rawEventSelection;
    parseTokenDeduplication[rawTokenDeduplication]; (* Token deduplication is not implemented at the moment *)
    parseEventOrdering[rawEventOrdering];           (* Event ordering is not implemented at the moment *)
    {maxEvents} = Values @ rawStoppingCondition;
    init = parseInit[rawInit];

    (* "HashTable" is causing memory leaks, so we are using Data`UnorderedAssociation instead. *)

    expressions = CreateDataStructure["DynamicArray", init];
    eventRuleIndices = CreateDataStructure["DynamicArray", {0}]; (* the first event is the initial event *)
    eventInputs = CreateDataStructure["DynamicArray", {{}}];
    eventOutputs = CreateDataStructure["DynamicArray", {Range @ Length @ init}];
    eventGenerations = CreateDataStructure["DynamicArray", {0}];
    expressionCreatorEvents = CreateDataStructure["DynamicArray", ConstantArray[1, Length @ init]];
    expressionDestroyerEventCounts = CreateDataStructure["DynamicArray", ConstantArray[0, Length @ init]];
    (* destroyerChoices[eventID][expressionID] -> eventID. See libSetReplace/Event.cpp for more information. *)
    destroyerChoices = CreateDataStructure["DynamicArray", {Data`UnorderedAssociation[]}];
    (* The numbers of times ordered sequences of event inputs were instantiated. This might be larger than 1 in
       left-hand sides of rules such as {a__, b__}. `All` means no further instantiations are possible. *)
    instantiationCounts = Data`UnorderedAssociation[];
    (* This stores possible instantiations for particular ordered sequences of input expressions. The instantiations are
       stored at the time of matching and are deleted once all possible instantiations are turned into events. This
       avoids the need to evaluate the same right-hand sides of rules multiple times. *)
    instantiations = Data`UnorderedAssociation[];

    (* Data structures are modified in-place. If the system runs out of matches, it throws an exception. *)
    terminationReason = Catch[
      Do[
        evaluateSingleEvent[rules, maxGeneration, maxDestroyerEvents, minEventInputs, maxEventInputs],
          Replace[maxEvents, Infinity -> 2^63 - 1]];
      "MaxEvents"
    ,
      $$terminationReason
    ];

    Multihistory[
      {MultisetSubstitutionSystem, 0},
      <|"Rules" -> rules,
        "TerminationReason" -> terminationReason,
        "Expressions" -> expressions,
        "EventRuleIndices" -> eventRuleIndices,
        "EventInputs" -> eventInputs,
        "EventOutputs" -> eventOutputs,
        "EventGenerations" -> eventGenerations,
        "ExpressionCreatorEvents" -> expressionCreatorEvents,
        "ExpressionDestroyerEventCounts" -> expressionDestroyerEventCounts,
        "DestroyerChoices" -> destroyerChoices,
        "InstantiationCounts" -> instantiationCounts,
        "Instantiations" -> instantiations|>]
]];

(* Evaluation *)

evaluateSingleEvent[
    rules_, maxGeneration_, maxDestroyerEvents_, minEventInputs_, maxEventInputs_] := ModuleScope[
  {ruleIndex, matchedExpressions} = findMatch[rules, maxGeneration, maxDestroyerEvents, minEventInputs, maxEventInputs];
  createEvent[ruleIndex, matchedExpressions]
];

(* Matching *)

findMatch[rules_, maxGeneration_, maxDestroyerEvents_, minEventInputs_, maxEventInputs_] := ModuleScope[
  eventInputsCountRange = {minEventInputs, Min[maxEventInputs, expressions["Length"]]};
  subsetCount = With[{n = expressions["Length"], a = eventInputsCountRange[[1]], b = eventInputsCountRange[[2]]},
    (* Sum[Binomial[n, k], {k, a, b}] *)
    Binomial[n, a] * Hypergeometric2F1[1, a - n, 1 + a, -1] -
      Binomial[n, 1 + b] * Hypergeometric2F1[1, 1 + b - n, 2 + b, -1]
  ];

  (* Matching is currently rather inefficient, because it enumerates all subsets no matter what.
     Three things need to happen to make it faster:
     1. We need to do some rule introspection to determine what to search for. For example, for some rules, we can
        automatically determine the number of input expressions, in which case we don't have to enumerate all subsets
        anymore. We can also make an atoms index for some rules (like we do in Matcher of libSetReplace). In this case,
        we can avoid searching entire subtrees if we see some expressions as non-intersecting.
     2. We need to skip expressions from matching based on metadata. For example, we shouldn't continue matching groups
        that are not spacelike or have exceeding generations or destroyer event count.
     3. We need to save partial searching results. They can probably be saved as non-intersecting ranges. Note that they
        have to be ranges because adding new expressions will introduce gaps in the sequence of matches ordered
        according to some (but not all) ordering functions. This new data structure will replace instantiationCounts
        which currently uses unnecessarily large amount of memory by storing each tried match individually. *)
  ScopeVariable[subsetIndex, possibleMatch, ruleIndex];
  Do[
    If[Lookup[instantiationCounts, Key[{ruleIndex, possibleMatch}], 0] =!= All &&
        AllTrue[expressionDestroyerEventCounts["Part", #] & /@ possibleMatch, # < maxDestroyerEvents &] &&
        AllTrue[possibleMatch, eventGenerations["Part", expressionCreatorEvents["Part", #]] < maxGeneration &] &&
        createInstantiationsIfPossible[rules][ruleIndex, possibleMatch],
      Return[{ruleIndex, possibleMatch}, Module]
    ];
  ,
    {subsetIndex, 1, Min[subsetCount, 2 ^ 63 - 1]},
    {possibleMatch, Permutations[First @ Subsets[Range @ expressions["Length"], eventInputsCountRange, {subsetIndex}]]},
    {ruleIndex, Range @ Length @ rules}
  ];
  Throw["Complete", $$terminationReason];
];

declareMessage[General::ruleInstantiationMessage,
               "Messages encountered while instantiating the rule `rule` for inputs `inputs`."];
declareMessage[General::ruleOutputNotList, "Rule `rule` for inputs `inputs` did not generate a List."];

(* This checks if possibleMatch matches the rules and that its expressions are spacelike separated. If so, it generates
   the instantiations, and returns True. If the match is not possible, adds All to instantiationCounts to avoid checking
   the same potential match in the future. *)
createInstantiationsIfPossible[rules_][ruleIndex_, possibleMatch_] := ModuleScope[
  ruleInputContents = expressions["Part", #] & /@ possibleMatch;
  Check[
    outputs = Lookup[instantiations,
                     Key[{ruleIndex, possibleMatch}],
                     ReplaceList[expressions["Part", #] & /@ possibleMatch, rules[[ruleIndex]]]];
  ,
    throw[Failure[
      "ruleInstantiationMessage",
      <|"rule" -> rules[[ruleIndex]], "inputs" -> ruleInputContents|>]];
  ];
  If[!ListQ[#],
    throw[Failure["ruleOutputNotList", <|"rule" -> rules[[ruleIndex]], "inputs" -> ruleInputContents|>]]
  ] & /@ outputs;
  If[KeyExistsQ[instantiations, {ruleIndex, possibleMatch}],
    (* We already checked by this point that additional instantiations remain *)
    True
  ,
    If[Length[outputs] > 0 && spacelikeExpressionsQ[possibleMatch],
      instantiations[{ruleIndex, possibleMatch}] = outputs;
      True
    ,
      instantiationCounts[{ruleIndex, possibleMatch}] = All;
      False
    ]
  ]
];

spacelikeExpressionsQ[expressions_] := ModuleScope[
  AllTrue[
    Subsets[expressions, {2}], expressionsSeparation @@ # === "Spacelike" &]
];

expressionsSeparation[firstExpression_, secondExpression_] := ModuleScope[
  If[firstExpression === secondExpression, Return["Identical", Module]];

  {firstDestroyerChoices, secondDestroyerChoices} =
    destroyerChoices["Part", expressionCreatorEvents["Part", #]] & /@ {firstExpression, secondExpression};

  If[KeyExistsQ[firstDestroyerChoices, secondExpression] || KeyExistsQ[secondDestroyerChoices, firstExpression],
    Return["Timelike", Module]
  ];

  KeyValueMap[Function[{expression, chosenEvent},
    If[KeyExistsQ[secondDestroyerChoices, expression] && secondDestroyerChoices[expression] =!= chosenEvent,
      Return["Branchlike", Module];
    ];
  ], firstDestroyerChoices];
  "Spacelike"
];

createEvent[ruleIndex_, matchedExpressions_] := ModuleScope[
  ruleInputContents = expressions["Part", #] & /@ matchedExpressions;
  possibleOutputs = instantiations[{ruleIndex, matchedExpressions}];
  possibleMatchCount = Length[possibleOutputs];
  currentInstantiationIndex = Lookup[instantiationCounts, Key[{ruleIndex, matchedExpressions}], 0] + 1;
  outputExpressions = possibleOutputs[[currentInstantiationIndex]];
  expressions["Append", #] & /@ outputExpressions;

  eventRuleIndices["Append", ruleIndex];
  eventInputs["Append", matchedExpressions];
  instantiationCounts[{ruleIndex, matchedExpressions}] =
    If[currentInstantiationIndex === possibleMatchCount, All, currentInstantiationIndex];
  (* Need a nested list because KeyDropFrom interprets {ruleIndex, matchedExpressions} as two keys otherwise. *)
  If[currentInstantiationIndex === possibleMatchCount,
    KeyDropFrom[instantiations, Key[{ruleIndex, matchedExpressions}]]
  ];
  eventOutputs["Append", Range[expressions["Length"] - Length[outputExpressions] + 1, expressions["Length"]]];

  inputExpressionCreatorEvents = expressionCreatorEvents["Part", #] & /@ matchedExpressions;
  inputExpressionGenerations = eventGenerations["Part", #] & /@ inputExpressionCreatorEvents;
  eventGenerations["Append", Max[inputExpressionGenerations, -1] + 1];

  Do[expressionCreatorEvents["Append", eventRuleIndices["Length"]], Length[outputExpressions]];

  Do[expressionDestroyerEventCounts["Append", 0], Length[outputExpressions]];
  Scan[
    expressionDestroyerEventCounts["SetPart", #, expressionDestroyerEventCounts["Part", #] + 1] &, matchedExpressions];

  newDestroyerChoices = Data`UnorderedAssociation[];
  Scan[(
    newDestroyerChoices[#] = eventRuleIndices["Length"];
    inputEvent = expressionCreatorEvents["Part", #];
    KeyValueMap[Function[{expression, chosenEvent},
      newDestroyerChoices[expression] = chosenEvent;
    ], destroyerChoices["Part", inputEvent]];
  ) &, matchedExpressions];
  destroyerChoices["Append", newDestroyerChoices];
];

(* Parsing *)

$singleRulePattern = _Rule | _RuleDelayed;
parseRules[rawRules : $singleRulePattern] := {rawRules};
parseRules[rawRules : {$singleRulePattern...}] := rawRules;
declareMessage[General::invalidMultisetRules, "Rules `rules` must be a Rule, a RuleDelayed or a List of them."];
parseRules[rawRules_] := throw[Failure["invalidMultisetRules", <|"rules" -> rawRules|>]];
parseRules[rawRules___] /; !CheckArguments[MultisetSubstitutionSystem[rawRules], 1] := throw[Failure[None, <||>]];

parseTokenDeduplication[None] := None;
declareMessage[General::multisetTokenDeduplicationNotImplemented,
               "Token deduplication is not implemented for Multiset Substitution System."];
parseTokenDeduplication[_] := throw[Failure["multisetTokenDeduplicationNotImplemented", <||>]];

$supportedEventOrdering =
  {"InputCount", "SortedInputTokenIndices", "InputTokenIndices", "RuleIndex", "InstantiationIndex"};
parseEventOrdering[ordering : $supportedEventOrdering] := ordering;
declareMessage[General::multisetEventOrderingNotImplemented,
               "Only " <> ToString[$supportedEventOrdering] <> " event ordering is implemented at this time."];
parseEventOrdering[_] := throw[Failure["multisetEventOrderingNotImplemented", <||>]];

parseInit[init_List] := init;
declareMessage[General::multisetInitNotList, "Multiset Substitution System init `init` should be a List."];
parseInit[init_] := throw[Failure["multisetInitNotList", <|"init" -> init|>]];

(* ::Package:: *)

(* ::Title:: *)
(*WolframModelEvolutionObject*)


(* ::Text:: *)
(*This is an object that is returned by WolframModel. It allows one to query the set at different generations and different steps.*)


Package["SetReplace`"]


PackageExport["WolframModelEvolutionObject"]


PackageScope["propertyEvaluate"]


PackageScope["$propertiesParameterless"]


(* ::Text:: *)
(*Keys in the data association.*)


PackageScope["$creatorEvents"]
PackageScope["$destroyerEvents"]
PackageScope["$generations"]
PackageScope["$atomLists"]
PackageScope["$rules"]
PackageScope["$maxCompleteGeneration"]
PackageScope["$terminationReason"]


(* ::Section:: *)
(*Documentation*)


WolframModelEvolutionObject::usage = usageString[
	"WolframModelEvolutionObject[`...`] is an evolution object generated by ",
	"WolframModel.",
	"\n",
	"WolframModelEvolutionObject[`...`][`g`] yields the set at generation `g`.",
	"\n",
	"WolframModelEvolutionObject[`...`][\"SetAfterEvent\", `s`] yields the state ",
	"after `s` substitution events.",
	"\n",
	"WolframModelEvolutionObject[`...`][\"Properties\"] yields the list of all ",
	"available properties."];


(* ::Section:: *)
(*SyntaxInformation*)


SyntaxInformation[WolframModelEvolutionObject] = {"ArgumentsPattern" -> {___}};


(* ::Section:: *)
(*Boxes*)


WolframModelEvolutionObject /:
		MakeBoxes[
			evo : WolframModelEvolutionObject[data_ ? evolutionDataQ],
			format_] := Module[
	{generationsCount, maxCompleteGeneration, eventsCount, terminationReason, rules, initialSet},
	generationsCount = evo["GenerationsCount"];
	maxCompleteGeneration = Replace[evo["MaxCompleteGeneration"], _ ? MissingQ -> "?"];
	generationsDisplay = If[generationsCount === maxCompleteGeneration,
		generationsCount,
		Row[{maxCompleteGeneration, "\[Ellipsis]", generationsCount}]];
	eventsCount = evo["EventsCount"];
	terminationReason = evo["TerminationReason"];
	rules = data[$rules];
	initialSet = evo[0];
	BoxForm`ArrangeSummaryBox[
		WolframModelEvolutionObject,
		evo,
		$graphIcon,
		(* Always grid *)
		{{BoxForm`SummaryItem[{"Generations: ", generationsDisplay}]},
		{BoxForm`SummaryItem[{"Events: ", eventsCount}]}},
		(* Sometimes grid *)
		{If[MissingQ[terminationReason], Nothing, {BoxForm`SummaryItem[{"Termination reason: ", terminationReason}]}],
		{BoxForm`SummaryItem[{"Rules: ", Short[rules]}]},
		{BoxForm`SummaryItem[{"Initial set: ", Short[initialSet]}]}},
		format,
		"Interpretable" -> Automatic
	]
]


(* ::Section:: *)
(*Implementation*)


$accessorProperties = <|
	"CreatorEvents" -> $creatorEvents,
	"DestroyerEvents" -> $destroyerEvents,
	"ExpressionGenerations" -> $generations,
	"AllExpressions" -> $atomLists,
	"MaxCompleteGeneration" -> $maxCompleteGeneration
|>;


$propertyArgumentCounts = Join[
	<|
		"EvolutionObject" -> {0, 0},
		"FinalState" -> {0, 0},
		"StatesList" -> {0, 0},
		"UpdatedStatesList" -> {0, 0},
		"Generation" -> {1, 1},
		"SetAfterEvent" -> {1, 1},
		"Rules" -> {0, 0},
		"GenerationsCount" -> {0, 0},
		"EventsCount" -> {0, 0},
		"AtomsCountFinal" -> {0, 0},
		"AtomsCountTotal" -> {0, 0},
		"ExpressionsCountFinal" -> {0, 0},
		"ExpressionsCountTotal" -> {0, 0},
		"EventGenerations" -> {0, 0},
		"CausalGraph" -> {0, Infinity},
		"LayeredCausalGraph" -> {0, Infinity},
		"TerminationReason" -> {0, 0},
		"Properties" -> {0, 0}|>,
	Association[# -> {0, 0} & /@ Keys[$accessorProperties]]];


$propertiesParameterless = Keys @ Select[#[[1]] == 0 &] @ $propertyArgumentCounts;


(* ::Subsection:: *)
(*Argument checks*)


(* ::Subsection:: *)
(*Master options handling*)


General::missingMaxCompleteGeneration = "Cannot drop incomplete generations in an object with missing information.";


propertyEvaluate[False, boundary_][evolution_, caller_, rest___] := If[MissingQ[evolution["MaxCompleteGeneration"]],
	Message[caller::missingMaxCompleteGeneration],
	propertyEvaluate[True, boundary][deleteIncompleteGenerations[evolution], caller, rest]
]


propertyEvaluate[includePartialGenerations : Except[True | False], _][evolution_, caller_, ___] :=
	Message[caller::invalidFiniteOption, "IncludePartialGenerations", includePartialGenerations, {True, False}]


includeBounaryEventsPattern = None | "Initial" | "Final" | All;


propertyEvaluate[_, boundary : Except[includeBounaryEventsPattern]][evolution_, caller_, ___] :=
	Message[caller::invalidFiniteOption, "IncludeBoundaryEvents", boundary, {None, "Initial", "Final", All}]


deleteIncompleteGenerations[WolframModelEvolutionObject[data_]] := Module[{
		maxCompleteGeneration, expressionsToDelete, lastGenerationExpressions, deleteEventsRules},
	maxCompleteGeneration = data[$maxCompleteGeneration];
	{expressionsToDelete, lastGenerationExpressions} =
		Position[data[$generations], _ ? #][[All, 1]] & /@ {# > maxCompleteGeneration &, # == maxCompleteGeneration &};
	expressionsToKeep = Complement[Range[Length[data[$generations]]], expressionsToDelete];
	deleteEventsRules = Dispatch[Thread[
		Union[data[$creatorEvents][[expressionsToDelete]], data[$destroyerEvents][[lastGenerationExpressions]]] ->
			Infinity]];
	WolframModelEvolutionObject[<|
		$creatorEvents -> data[$creatorEvents][[expressionsToKeep]],
		$destroyerEvents -> data[$destroyerEvents][[expressionsToKeep]] /. deleteEventsRules,
		$generations -> data[$generations][[expressionsToKeep]],
		$atomLists -> data[$atomLists][[expressionsToKeep]],
		$rules -> data[$rules],
		$maxCompleteGeneration -> data[$maxCompleteGeneration],
		$terminationReason -> data[$terminationReason]
	|>]
]


(* ::Subsubsection:: *)
(*Unknown property*)


propertyEvaluate[___][
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		s : Except[_Integer],
		___] := 0 /;
	!MemberQ[Keys[$propertyArgumentCounts], s] &&
	makeMessage[caller, "unknownProperty", s]


(* ::Subsubsection:: *)
(*Property argument counts*)


makePargxMessage[property_, caller_, givenArgs_, expectedArgs_] := makeMessage[
	caller,
	"pargx",
	property,
	givenArgs,
	If[givenArgs == 1, "", "s"],
	If[expectedArgs[[1]] != expectedArgs[[2]], "between ", ""],
	expectedArgs[[1]],
	If[expectedArgs[[1]] != expectedArgs[[2]], " and ", ""],
	If[expectedArgs[[1]] != expectedArgs[[2]], expectedArgs[[2]], ""],
	If[expectedArgs[[1]] != expectedArgs[[2]] || expectedArgs[[1]] != 1, "s", ""],
	If[expectedArgs[[1]] != expectedArgs[[2]] || expectedArgs[[1]] != 1, "are", "is"]
]


propertyEvaluate[___][
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		s_String,
		args___] := 0 /;
	With[{argumentsCountRange = $propertyArgumentCounts[s]},
		Not[MissingQ[argumentsCountRange]] &&
		Not[argumentsCountRange[[1]] <= Length[{args}] <= argumentsCountRange[[2]]] &&
		makePargxMessage[s, caller, Length[{args}], argumentsCountRange]]


(* ::Subsection:: *)
(*Properties*)


propertyEvaluate[___][
		WolframModelEvolutionObject[data_ ? evolutionDataQ], caller_, "Properties"] :=
	Keys[$propertyArgumentCounts]


(* ::Subsection:: *)
(*EvolutionObject*)


propertyEvaluate[True, includeBounaryEventsPattern][
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"EvolutionObject"] := WolframModelEvolutionObject[data]


(* ::Subsection:: *)
(*Rules*)


propertyEvaluate[___][
		WolframModelEvolutionObject[data_ ? evolutionDataQ], caller_, "Rules"] :=
	data[$rules]


(* ::Subsection:: *)
(*GenerationsCount*)


propertyEvaluate[True, includeBounaryEventsPattern][
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"GenerationsCount"] := Max[
	0,
	Max @ data[$generations],
	1 + Max @ data[$generations][[
		Position[
			data[$destroyerEvents], Except[Infinity], {1}, Heads -> False][[All, 1]]]]]


(* ::Subsection:: *)
(*EventsCount*)


propertyEvaluate[True, includeBoundaryEvents : includeBounaryEventsPattern][
		WolframModelEvolutionObject[data_ ? evolutionDataQ], caller_, "EventsCount"] :=
	Max[0, DeleteCases[Join[data[$destroyerEvents], data[$creatorEvents]], Infinity]] +
		Switch[includeBoundaryEvents, None, 0, "Initial" | "Final", 1, All, 2]


(* ::Subsection:: *)
(*Direct Accessors*)


propertyEvaluate[True, includeBounaryEventsPattern][
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		property_ ? (MemberQ[Keys[$accessorProperties], #] &)] :=
	Lookup[data, $accessorProperties[property], Missing["NotAvailable"]];


(* ::Subsection:: *)
(*SetAfterEvent*)


(* ::Subsubsection:: *)
(*Argument checks*)


propertyEvaluate[True, includeBounaryEventsPattern][
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"SetAfterEvent",
		s_Integer] := 0 /;
	With[{eventsCount =
			propertyEvaluate[True, None][
				WolframModelEvolutionObject[data], caller, "EventsCount"]},
		!(- eventsCount - 1 <= s <= eventsCount) &&
		makeMessage[caller, "eventTooLarge", s, eventsCount]]


propertyEvaluate[True, includeBounaryEventsPattern][
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"SetAfterEvent",
		s_] := 0 /;
	!IntegerQ[s] &&
	makeMessage[caller, "eventNotInteger", s]


(* ::Subsubsection:: *)
(*Positive steps*)


propertyEvaluate[True, includeBounaryEventsPattern][
			WolframModelEvolutionObject[data_ ? evolutionDataQ],
			caller_,
			"SetAfterEvent",
			s_Integer] /;
		0 <= s <= propertyEvaluate[True, None][
			WolframModelEvolutionObject[data], caller, "EventsCount"] :=
	data[$atomLists][[Intersection[
		Position[data[$creatorEvents], _ ? (# <= s &)][[All, 1]],
		Position[data[$destroyerEvents], _ ? (# > s &)][[All, 1]]]]]


(* ::Subsubsection:: *)
(*Negative steps*)


propertyEvaluate[True, includeBounaryEventsPattern][
			WolframModelEvolutionObject[data_ ? evolutionDataQ],
			caller_,
			"SetAfterEvent",
			s_Integer] /;
		- propertyEvaluate[True, None][
			WolframModelEvolutionObject[data], caller, "EventsCount"] - 1 <= s < 0 :=
	propertyEvaluate[True, None][
		WolframModelEvolutionObject[data],
		caller,
		"SetAfterEvent",
		s + 1 + propertyEvaluate[True, None][
			WolframModelEvolutionObject[data], caller, "EventsCount"]]


(* ::Subsection:: *)
(*FinalState*)


propertyEvaluate[True, includeBounaryEventsPattern][
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"FinalState"] := WolframModelEvolutionObject[data]["SetAfterEvent", -1]


(* ::Subsection:: *)
(*UpdatedStatesList*)


propertyEvaluate[True, includeBounaryEventsPattern][
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"UpdatedStatesList"] :=
	WolframModelEvolutionObject[data]["SetAfterEvent", #] & /@
		Range[0, WolframModelEvolutionObject[data]["EventsCount"]]


(* ::Subsection:: *)
(*Generation*)


(* ::Text:: *)
(*Note that depending on how evaluation was done (i.e., the order of substitutions), it is possible that some expressions of a requested generation were not yet produced, and thus expressions for the previous generation would be used instead. That, however, should never happen if the evolution object is produced with WolframModel.*)


(* ::Subsubsection:: *)
(*Argument checks*)


propertyEvaluate[True, includeBounaryEventsPattern][
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"Generation",
		g_Integer] := 0 /;
	With[{generationsCount = propertyEvaluate[True, None][
			WolframModelEvolutionObject[data], caller, "GenerationsCount"]},
		!(- generationsCount - 1 <= g <= generationsCount) &&
		makeMessage[caller, "generationTooLarge", g, generationsCount]]


propertyEvaluate[True, includeBounaryEventsPattern][
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"Generation",
		g_] := 0 /;
	!IntegerQ[g] &&
	makeMessage[caller, "generationNotInteger", g]


(* ::Subsubsection:: *)
(*Positive generations*)


propertyEvaluate[True, includeBounaryEventsPattern][
			WolframModelEvolutionObject[data_ ? evolutionDataQ],
			caller_,
			"Generation",
			g_Integer] /;
		0 <= g <= propertyEvaluate[True, None][
			WolframModelEvolutionObject[data], caller, "GenerationsCount"] := With[{
	futureEventsToInfinity = Dispatch @ Thread[Union[
			data[$creatorEvents][[
				Position[data[$generations], _ ? (# > g &)][[All, 1]]]],
			data[$destroyerEvents][[
				Position[data[$generations], _ ? (# >= g &)][[All, 1]]]]] ->
		Infinity]},
	data[$atomLists][[Intersection[
		Position[
			data[$creatorEvents] /. futureEventsToInfinity,
			Except[Infinity],
			1,
			Heads -> False][[All, 1]],
		Position[
			data[$destroyerEvents] /. futureEventsToInfinity, Infinity][[All, 1]]]]]]


(* ::Subsubsection:: *)
(*Negative generations*)


propertyEvaluate[True, includeBounaryEventsPattern][
			WolframModelEvolutionObject[data_ ? evolutionDataQ],
			caller_,
			"Generation",
			g_Integer] /;
		- propertyEvaluate[True, None][
			WolframModelEvolutionObject[data],
			caller,
			"GenerationsCount"] - 1 <= g < 0 :=
	propertyEvaluate[True, None][
		WolframModelEvolutionObject[data],
		caller,
		"Generation",
		g + 1 + WolframModelEvolutionObject[data]["GenerationsCount"]]


(* ::Subsubsection:: *)
(*Omit "Generation"*)


propertyEvaluate[True, includeBounaryEventsPattern][
		WolframModelEvolutionObject[data_ ? evolutionDataQ], caller_, g_Integer] :=
	propertyEvaluate[True, None][WolframModelEvolutionObject[data], caller, "Generation", g]


(* ::Subsection:: *)
(*StatesList*)


propertyEvaluate[True, includeBounaryEventsPattern][
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"StatesList"] :=
	WolframModelEvolutionObject[data]["Generation", #] & /@
		Range[0, WolframModelEvolutionObject[data]["GenerationsCount"]]


(* ::Subsection:: *)
(*AtomsCountFinal*)


propertyEvaluate[True, includeBounaryEventsPattern][
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"AtomsCountFinal"] :=
	Length[Union @ Cases[
		propertyEvaluate[True, None][
			WolframModelEvolutionObject[data], caller, "SetAfterEvent", -1],
		_ ? AtomQ,
		All]]


(* ::Subsection:: *)
(*AtomsCountTotal*)


propertyEvaluate[True, includeBounaryEventsPattern][
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"AtomsCountTotal"] :=
	Length[Union @ Cases[data[$atomLists], _ ? AtomQ, All]]


(* ::Subsection:: *)
(*ExpressionsCountFinal*)


propertyEvaluate[True, includeBounaryEventsPattern][
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"ExpressionsCountFinal"] :=
	Length[propertyEvaluate[True, None][
		WolframModelEvolutionObject[data], caller, "SetAfterEvent", -1]]


(* ::Subsection:: *)
(*ExpressionsCountTotal*)


propertyEvaluate[True, includeBounaryEventsPattern][
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"ExpressionsCountTotal"] :=
	Length[data[$atomLists]]


(* ::Subsection:: *)
(*EventGenerations*)


propertyEvaluate[True, includeBoundaryEvents : includeBounaryEventsPattern][
		evolution : WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"EventGenerations"] :=
	If[MatchQ[includeBoundaryEvents, All | "Final"], Append[evolution["GenerationsCount"] + 1], Identity] @
		If[MatchQ[includeBoundaryEvents, All | "Initial"], Prepend[0], Identity] @
		Values @
		KeySort @
		KeyDrop[
			Join[
				Association[Thread[data[$creatorEvents] -> data[$generations]]],
				Association[Thread[data[$destroyerEvents] -> data[$generations] + 1]]],
			{0, Infinity}]


(* ::Subsection:: *)
(*CausalGraph / LayeredCausalGraph*)


(* ::Text:: *)
(*This produces a causal network for the system. This is a Graph with all events as vertices, and directed edges connecting them if the same event is a creator and a destroyer for the same expression (i.e., if two events are causally related).*)


(* ::Subsubsection:: *)
(*Options*)


$causalGraphOptions = Options[Graph];


$layeredCausalGraphOptions = Options[$causalGraphOptions];


(* ::Subsubsection:: *)
(*Argument checks*)


(* ::Text:: *)
(*We need to check: (1) arguments given are actually options, (2) they are valid options for the Graph object.*)


propertyEvaluate[True, includeBounaryEventsPattern][
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"CausalGraph" | "LayeredCausalGraph",
		o___] := 0 /;
	!MatchQ[{o}, OptionsPattern[]] &&
	makeMessage[caller, "nonopt", Last[{o}]]


propertyEvaluate[True, includeBounaryEventsPattern][
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		property : "CausalGraph" | "LayeredCausalGraph",
		o : OptionsPattern[]] := 0 /; Module[{allOptions, incorrectOptions},
	allOptions =
		If[property == "CausalGraph", $causalGraphOptions, $layeredCausalGraphOptions];
	incorrectOptions = Complement[{o}, FilterRules[{o}, allOptions]];
	incorrectOptions != {} &&
		Message[
			caller::optx,
			Last[incorrectOptions],
			Defer[WolframModelEvolutionObject[data][property, o]]]
]


(* ::Subsubsection:: *)
(*CausalGraph Implementation*)


propertyEvaluate[True, includeBoundaryEvents : includeBounaryEventsPattern][
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"CausalGraph",
		o : OptionsPattern[]] /;
			(Complement[{o}, FilterRules[{o}, $causalGraphOptions]] == {}) := With[{
		eventsToDelete = Alternatives @@ (
			If[MatchQ[includeBoundaryEvents, All | #1], Nothing, #2] & @@@ {{"Initial", 0}, {"Final", Infinity}})},
	Graph[
		DeleteCases[Union[data[$creatorEvents], data[$destroyerEvents]], eventsToDelete],
		Select[FreeQ[#, eventsToDelete] &] @ Thread[data[$creatorEvents] \[DirectedEdge] data[$destroyerEvents]],
		o]
]


(* ::Subsubsection:: *)
(*LayeredCausalGraph Implementation*)


propertyEvaluate[True, includeBoundaryEvents : includeBounaryEventsPattern][
		evolution : WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"LayeredCausalGraph",
		o : OptionsPattern[]] /;
			(Complement[{o}, FilterRules[{o}, $layeredCausalGraphOptions]] == {}) :=
	Graph[
		propertyEvaluate[True, includeBoundaryEvents][evolution, caller, "CausalGraph", ##] & @@
			FilterRules[{o}, $causalGraphOptions],
		FilterRules[{o}, Options[Graph]],
		GraphLayout -> {
			"LayeredDigraphEmbedding",
			"VertexLayerPosition" ->
				(propertyEvaluate[True, includeBoundaryEvents][evolution, caller, "GenerationsCount"] -
						propertyEvaluate[True, includeBoundaryEvents][evolution, caller, "EventGenerations"])}
	]


(* ::Subsubsection:: *)
(*TerminationReason Implementation*)


propertyEvaluate[True, includeBounaryEventsPattern][
		evolution : WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"TerminationReason"] := Replace[data[[Key[$terminationReason]]], Join[Normal[$stepSpecKeys], {
	$fixedPoint -> "FixedPoint",
	$timeConstraint -> "TimeConstraint",
	$Aborted -> "Aborted",
	x_ ? MissingQ :> x,
	_ -> Missing["NotAvailable"]
}]]


(* ::Subsection:: *)
(*Public properties call*)


$masterOptions = {
	"IncludePartialGenerations" -> True,
	"IncludeBoundaryEvents" -> None
};


WolframModelEvolutionObject[
		data_ ? evolutionDataQ][
		property___ ? (Not[MatchQ[#, OptionsPattern[]]] &),
		opts : OptionsPattern[]] := Module[{prunedObject, result},
	result = Check[
		(propertyEvaluate @@
				(OptionValue[Join[{opts}, $masterOptions], #] & /@ {"IncludePartialGenerations", "IncludeBoundaryEvents"}))[
			WolframModelEvolutionObject[data],
			WolframModelEvolutionObject,
			property,
			##] & @@ Flatten[FilterRules[{opts}, Except[$masterOptions]]],
		$Failed];
	result /; result =!= $Failed
]


(* ::Section:: *)
(*Argument Checks*)


(* ::Text:: *)
(*Argument Checks should be evaluated after Implementation, otherwise ::corrupt messages will be created while assigning SubValues.*)


(* ::Subsection:: *)
(*Argument count*)


WolframModelEvolutionObject[args___] := 0 /;
	!Developer`CheckArgumentCount[WolframModelEvolutionObject[args], 1, 1] && False


(* ::Subsection:: *)
(*Association has correct fields*)


WolframModelEvolutionObject::corrupt =
	"WolframModelEvolutionObject does not have a correct format. " <>
	"Use WolframModel for construction.";


evolutionDataQ[data_Association] :=
	SubsetQ[
		Keys[data],
		{$creatorEvents, $destroyerEvents, $generations, $atomLists, $rules}] &&
	SubsetQ[
		{$creatorEvents, $destroyerEvents, $generations, $atomLists, $rules, $maxCompleteGeneration, $terminationReason},
		Keys[data]
	]


evolutionDataQ[___] := False


WolframModelEvolutionObject[data_] := 0 /;
	!evolutionDataQ[data] &&
	Message[WolframModelEvolutionObject::corrupt]

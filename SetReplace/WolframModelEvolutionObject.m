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
	{generationsCount, eventsCount, rules, initialSet},
	generationsCount = evo["GenerationsCount"];
	eventsCount = evo["EventsCount"];
	rules = data[$rules];
	initialSet = evo[0];
	BoxForm`ArrangeSummaryBox[
		WolframModelEvolutionObject,
		evo,
		$graphIcon,
		(* Always grid *)
		{{BoxForm`SummaryItem[{"Generations count: ", generationsCount}]},
		{BoxForm`SummaryItem[{"Events count: ", eventsCount}]}},
		(* Sometimes grid *)
		{{BoxForm`SummaryItem[{"Rules: ", Short[rules]}]},
		{BoxForm`SummaryItem[{"Initial set: ", Short[initialSet]}]}},
		format,
		"Interpretable" -> Automatic
	]
]


(* ::Section:: *)
(*Implementation*)


$propertyArgumentCounts = <|
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
	"CausalGraph" -> {0, Infinity},
	"Properties" -> {0, 0}
|>;


$propertiesParameterless = Keys @ Select[#[[1]] == 0 &] @ $propertyArgumentCounts;


(* ::Subsection:: *)
(*Argument checks*)


(* ::Subsubsection:: *)
(*Unknown property*)


propertyEvaluate[
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


propertyEvaluate[
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


propertyEvaluate[
		WolframModelEvolutionObject[data_ ? evolutionDataQ], caller_, "Properties"] :=
	Keys[$propertyArgumentCounts]


(* ::Subsection:: *)
(*EvolutionObject*)


propertyEvaluate[
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"EvolutionObject"] := WolframModelEvolutionObject[data]


(* ::Subsection:: *)
(*Rules*)


propertyEvaluate[
		WolframModelEvolutionObject[data_ ? evolutionDataQ], caller_, "Rules"] :=
	data[$rules]


(* ::Subsection:: *)
(*GenerationsCount*)


propertyEvaluate[
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


propertyEvaluate[
		WolframModelEvolutionObject[data_ ? evolutionDataQ], caller_, "EventsCount"] :=
	Max[0, DeleteCases[Join[data[$destroyerEvents], data[$creatorEvents]], Infinity]]


(* ::Subsection:: *)
(*SetAfterEvent*)


(* ::Subsubsection:: *)
(*Argument checks*)


propertyEvaluate[
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"SetAfterEvent",
		s_Integer] := 0 /;
	With[{eventsCount =
			propertyEvaluate[
				WolframModelEvolutionObject[data], caller, "EventsCount"]},
		!(- eventsCount - 1 <= s <= eventsCount) &&
		makeMessage[caller, "eventTooLarge", s, eventsCount]]


propertyEvaluate[
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"SetAfterEvent",
		s_] := 0 /;
	!IntegerQ[s] &&
	makeMessage[caller, "eventNotInteger", s]


(* ::Subsubsection:: *)
(*Positive steps*)


propertyEvaluate[
			WolframModelEvolutionObject[data_ ? evolutionDataQ],
			caller_,
			"SetAfterEvent",
			s_Integer] /;
		0 <= s <= propertyEvaluate[
			WolframModelEvolutionObject[data], caller, "EventsCount"] :=
	data[$atomLists][[Intersection[
		Position[data[$creatorEvents], _ ? (# <= s &)][[All, 1]],
		Position[data[$destroyerEvents], _ ? (# > s &)][[All, 1]]]]]


(* ::Subsubsection:: *)
(*Negative steps*)


propertyEvaluate[
			WolframModelEvolutionObject[data_ ? evolutionDataQ],
			caller_,
			"SetAfterEvent",
			s_Integer] /;
		- propertyEvaluate[
			WolframModelEvolutionObject[data], caller, "EventsCount"] - 1 <= s < 0 :=
	propertyEvaluate[
		WolframModelEvolutionObject[data],
		caller,
		"SetAfterEvent",
		s + 1 + propertyEvaluate[
			WolframModelEvolutionObject[data], caller, "EventsCount"]]


(* ::Subsection:: *)
(*FinalState*)


propertyEvaluate[
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"FinalState"] := WolframModelEvolutionObject[data]["SetAfterEvent", -1]


(* ::Subsection:: *)
(*UpdatedStatesList*)


propertyEvaluate[
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


propertyEvaluate[
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"Generation",
		g_Integer] := 0 /;
	With[{generationsCount = propertyEvaluate[
			WolframModelEvolutionObject[data], caller, "GenerationsCount"]},
		!(- generationsCount - 1 <= g <= generationsCount) &&
		makeMessage[caller, "generationTooLarge", g, generationsCount]]


propertyEvaluate[
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"Generation",
		g_] := 0 /;
	!IntegerQ[g] &&
	makeMessage[caller, "generationNotInteger", g]


(* ::Subsubsection:: *)
(*Positive generations*)


propertyEvaluate[
			WolframModelEvolutionObject[data_ ? evolutionDataQ],
			caller_,
			"Generation",
			g_Integer] /;
		0 <= g <= propertyEvaluate[
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


propertyEvaluate[
			WolframModelEvolutionObject[data_ ? evolutionDataQ],
			caller_,
			"Generation",
			g_Integer] /;
		- propertyEvaluate[
			WolframModelEvolutionObject[data],
			caller,
			"GenerationsCount"] - 1 <= g < 0 :=
	propertyEvaluate[
		WolframModelEvolutionObject[data],
		caller,
		"Generation",
		g + 1 + WolframModelEvolutionObject[data]["GenerationsCount"]]


(* ::Subsubsection:: *)
(*Omit "Generation"*)


propertyEvaluate[
		WolframModelEvolutionObject[data_ ? evolutionDataQ], caller_, g_Integer] :=
	propertyEvaluate[WolframModelEvolutionObject[data], caller, "Generation", g]


(* ::Subsection:: *)
(*StatesList*)


propertyEvaluate[
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"StatesList"] :=
	WolframModelEvolutionObject[data]["Generation", #] & /@
		Range[0, WolframModelEvolutionObject[data]["GenerationsCount"]]


(* ::Subsection:: *)
(*AtomsCountFinal*)


propertyEvaluate[
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"AtomsCountFinal"] :=
	Length[Union @ Cases[
		propertyEvaluate[
			WolframModelEvolutionObject[data], caller, "SetAfterEvent", -1],
		_ ? AtomQ,
		All]]


(* ::Subsection:: *)
(*AtomsCountTotal*)


propertyEvaluate[
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"AtomsCountTotal"] :=
	Length[Union @ Cases[data[$atomLists], _ ? AtomQ, All]]


(* ::Subsection:: *)
(*ExpressionsCountFinal*)


propertyEvaluate[
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"ExpressionsCountFinal"] :=
	Length[propertyEvaluate[
		WolframModelEvolutionObject[data], caller, "SetAfterEvent", -1]]


(* ::Subsection:: *)
(*ExpressionsCountTotal*)


propertyEvaluate[
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"ExpressionsCountTotal"] :=
	Length[data[$atomLists]]


(* ::Subsection:: *)
(*CausalGraph*)


(* ::Text:: *)
(*This produces a causal network for the system. This is a Graph with all events as vertices, and directed edges connecting them if the same event is a creator and a destroyer for the same expression (i.e., if two events are causally related).*)


(* ::Subsubsection:: *)
(*Argument checks*)


(* ::Text:: *)
(*We need to check: (1) arguments given are actually options, (2) they are valid options for the Graph object.*)


propertyEvaluate[
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"CausalGraph",
		o___] := 0 /;
	!MatchQ[{o}, OptionsPattern[]] &&
	makeMessage[caller, "nonopt", Last[{o}]]


propertyEvaluate[
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"CausalGraph",
		o : OptionsPattern[]] := 0 /;
	With[{incorrectOptions = Complement[{o}, FilterRules[{o}, Options[Graph]]]},
		incorrectOptions != {} &&
		makeMessage[caller, "optx", Last[incorrectOptions]]]


(* ::Subsubsection:: *)
(*Implementation*)


propertyEvaluate[
		WolframModelEvolutionObject[data_ ? evolutionDataQ],
		caller_,
		"CausalGraph",
		o : OptionsPattern[]] /;
			(Complement[{o}, FilterRules[{o}, Options[Graph]]] == {}) :=
	Graph[
		DeleteCases[
			Union[data[$creatorEvents], data[$destroyerEvents]], 0 | Infinity],
		Select[FreeQ[#, 0 | Infinity] &] @
			Thread[data[$creatorEvents] \[DirectedEdge] data[$destroyerEvents]],
		o]


(* ::Subsection:: *)
(*Public properties call*)


WolframModelEvolutionObject[data_ ? evolutionDataQ][property___] := Module[{result},
	result = Check[
		propertyEvaluate[
			WolframModelEvolutionObject[data], WolframModelEvolutionObject, property],
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
	"WolframModelEvolutionObject does not have a correct format. Use WolframModel for construction.";


evolutionDataQ[data_Association] := Sort[Keys[data]] ===
	Sort[{$creatorEvents, $destroyerEvents, $generations, $atomLists, $rules}]


evolutionDataQ[___] := False


WolframModelEvolutionObject[data_] := 0 /;
	!evolutionDataQ[data] &&
	Message[WolframModelEvolutionObject::corrupt]

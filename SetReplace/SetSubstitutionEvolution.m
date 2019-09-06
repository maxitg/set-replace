(* ::Package:: *)

(* ::Title:: *)
(*SetSubstitutionEvolution*)


(* ::Text:: *)
(*This is an object that is returned by SetSubstitutionSystem. It allows one to query the set at different generations and different steps.*)


Package["SetReplace`"]


PackageExport["SetSubstitutionEvolution"]


(* ::Section:: *)
(*Documentation*)


SetSubstitutionEvolution::usage = usageString[
	"SetSubstitutionEvolution[`...`] is an evolution object generated by ",
	"SetSubstitutionSystem.",
	"\n",
	"SetSubstitutionEvolution[`...`][`g`] yields the set at generation `g`.",
	"\n",
	"SetSubstitutionEvolution[`...`][\"Step\", `s`] yields the set after `s` ",
	"substitution events.",
	"\n",
	"SetSubstitutionEvolution[`...`][\"Properties\"] yields the list of all ",
	"available properties."];


(* ::Section:: *)
(*SyntaxInformation*)


SyntaxInformation[SetSubstitutionEvolution] = {"ArgumentsPattern" -> {___}};


(* ::Section:: *)
(*Boxes*)


SetSubstitutionEvolution /:
		MakeBoxes[
			evo : SetSubstitutionEvolution[data_ ? evolutionDataQ],
			format_] := Module[
	{generationsCount, eventsCount, rules, initialSet},
	generationsCount = evo["GenerationsCount"];
	eventsCount = evo["EventsCount"];
	rules = data[$rules];
	initialSet = evo[0];
	BoxForm`ArrangeSummaryBox[
		SetSubstitutionEvolution,
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


$properties = {
	"Generation", "SetAfterEvent", "Rules", "GenerationsCount", "EventsCount",
	"AtomsCountFinal", "AtomsCountTotal",
	"ExpressionsCountFinal", "ExpressionsCountTotal",
	"Properties"};


(* ::Subsection:: *)
(*Argument checks*)


(* ::Subsubsection:: *)
(*Unknown property*)


SetSubstitutionEvolution::unknownProperty =
	"Property `` must be one of SetSubstitutionEvolution[...][\"Properties\"].";


SetSubstitutionEvolution[data_ ? evolutionDataQ][s : Except[_Integer], ___] := 0 /;
	!MemberQ[$properties, s] &&
	Message[SetSubstitutionEvolution::unknownProperty, s]


(* ::Subsubsection:: *)
(*Unknown property arguments*)


$propertiesWithArguments = {"Generation", "SetAfterEvent"};


SetSubstitutionEvolution::unknownArg = "Property `` does not accept any arguments.";


SetSubstitutionEvolution[data_ ? evolutionDataQ][s_String, args__] := 0 /;
	MemberQ[$properties, s] && !MemberQ[$propertiesWithArguments, s] &&
	Message[SetSubstitutionEvolution::unknownArg, s]


SetSubstitutionEvolution::pargx =
	"A single integer argument expected for property \"`1`\", i.e., " <>
	"SetSubstitutionEvolution[...][\"`1`\", n]."


SetSubstitutionEvolution[data_ ? evolutionDataQ][s_String, args___] := 0 /;
	MemberQ[$propertiesWithArguments, s] && Length[{args}] != 1 &&
	Message[SetSubstitutionEvolution::pargx, s]


(* ::Subsection:: *)
(*Properties*)


SetSubstitutionEvolution[data_ ? evolutionDataQ]["Properties"] := $properties


(* ::Subsection:: *)
(*Rules*)


SetSubstitutionEvolution[data_ ? evolutionDataQ]["Rules"] := data[$rules]


(* ::Subsection:: *)
(*GenerationsCount*)


SetSubstitutionEvolution[data_ ? evolutionDataQ]["GenerationsCount"] := Max[
	0,
	Max @ data[$generations],
	1 + Max @ data[$generations][[
		Position[
			data[$destroyerEvents], Except[Infinity], {1}, Heads -> False][[All, 1]]]]]


(* ::Subsection:: *)
(*EventsCount*)


SetSubstitutionEvolution[data_ ? evolutionDataQ]["EventsCount"] :=
	Max[0, DeleteCases[data[$destroyerEvents], Infinity]]


(* ::Subsection:: *)
(*Step*)


(* ::Subsubsection:: *)
(*Argument checks*)


SetSubstitutionEvolution::stepTooLarge = "Event `` requested out of `` total.";


SetSubstitutionEvolution[data_ ? evolutionDataQ]["SetAfterEvent", s_Integer] := 0 /;
	With[{eventsCount = SetSubstitutionEvolution[data]["EventsCount"]},
		!(- eventsCount - 1 <= s <= eventsCount) &&
		Message[SetSubstitutionEvolution::stepTooLarge, s, eventsCount]]


SetSubstitutionEvolution::stepNotInteger = "Event `` must be an integer.";


SetSubstitutionEvolution[data_ ? evolutionDataQ]["SetAfterEvent", s_] := 0 /;
	!IntegerQ[s] &&
	Message[SetSubstitutionEvolution::stepNotInteger, s]


(* ::Subsubsection:: *)
(*Positive steps*)


SetSubstitutionEvolution[data_ ? evolutionDataQ]["SetAfterEvent", s_Integer] /;
		0 <= s <= SetSubstitutionEvolution[data]["EventsCount"] :=
	data[$atomLists][[Intersection[
		Position[data[$creatorEvents], _ ? (# <= s &)][[All, 1]],
		Position[data[$destroyerEvents], _ ? (# > s &)][[All, 1]]]]]


(* ::Subsubsection:: *)
(*Negative steps*)


SetSubstitutionEvolution[data_ ? evolutionDataQ]["SetAfterEvent", s_Integer] /;
		- SetSubstitutionEvolution[data]["EventsCount"] - 1 <= s < 0 :=
	SetSubstitutionEvolution[data][
		"Step", s + 1 + SetSubstitutionEvolution[data]["EventsCount"]]


(* ::Subsection:: *)
(*Generation*)


(* ::Text:: *)
(*Note that depending on how evaluation was done (i.e., the order of substitutions), it is possible that some expressions of a requested generation were not yet produced, and thus expressions for the previous generation would be used instead. That, however, should never happen if the evolution object is produced with SetSubstitutionSystem.*)


(* ::Subsubsection:: *)
(*Argument checks*)


SetSubstitutionEvolution::generationTooLarge =
	"Generation `` requested out of `` total.";


SetSubstitutionEvolution[data_ ? evolutionDataQ]["Generation", g_Integer] := 0 /;
	With[{generationsCount = SetSubstitutionEvolution[data]["GenerationsCount"]},
		!(- generationsCount - 1 <= g <= generationsCount) &&
		Message[SetSubstitutionEvolution::generationTooLarge, g, generationsCount]]


SetSubstitutionEvolution::generationNotInteger = "Generation `` must be an integer.";


SetSubstitutionEvolution[data_ ? evolutionDataQ]["Generation", g_] := 0 /;
	!IntegerQ[g] &&
	Message[SetSubstitutionEvolution::generationNotInteger, g]


(* ::Subsubsection:: *)
(*Positive generations*)


SetSubstitutionEvolution[data_ ? evolutionDataQ]["Generation", g_Integer] /;
		0 <= g <= SetSubstitutionEvolution[data]["GenerationsCount"] := With[{
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


SetSubstitutionEvolution[data_ ? evolutionDataQ]["Generation", g_Integer] /;
		- SetSubstitutionEvolution[data]["GenerationsCount"] - 1 <= g < 0 :=
	SetSubstitutionEvolution[data][
		"Generation", g + 1 + SetSubstitutionEvolution[data]["GenerationsCount"]]


(* ::Subsubsection:: *)
(*Omit "Generation"*)


SetSubstitutionEvolution[data_ ? evolutionDataQ][g_Integer] :=
	SetSubstitutionEvolution[data]["Generation", g]


(* ::Subsection:: *)
(*AtomsCountFinal*)


SetSubstitutionEvolution[data_ ? evolutionDataQ]["AtomsCountFinal"] :=
	Length[Union @@ SetSubstitutionEvolution[data]["Step", -1]]


(* ::Subsection:: *)
(*AtomsCountTotal*)


SetSubstitutionEvolution[data_ ? evolutionDataQ]["AtomsCountTotal"] :=
	Length[Union @@ data[$atomLists]]


(* ::Subsection:: *)
(*ExpressionsCountFinal*)


SetSubstitutionEvolution[data_ ? evolutionDataQ]["ExpressionsCountFinal"] :=
	Length[SetSubstitutionEvolution[data]["Step", -1]]


(* ::Subsection:: *)
(*ExpressionsCountTotal*)


SetSubstitutionEvolution[data_ ? evolutionDataQ]["ExpressionsCountTotal"] :=
	Length[data[$atomLists]]


(* ::Section:: *)
(*Argument Checks*)


(* ::Text:: *)
(*Argument Checks should be evaluated after Implementation, otherwise ::corrupt messages will be created while assigning SubValues.*)


(* ::Subsection:: *)
(*Argument count*)


SetSubstitutionEvolution[args___] := 0 /;
	!Developer`CheckArgumentCount[SetSubstitutionEvolution[args], 1, 1] && False


(* ::Subsection:: *)
(*Association has correct fields*)


SetSubstitutionEvolution::corrupt =
	"SetSubstitutionEvolution does not have a correct format. " ~~
	"Use SetSubstitutionSystem for construction.";


evolutionDataQ[data_Association] := Sort[Keys[data]] ===
	Sort[{$creatorEvents, $destroyerEvents, $generations, $atomLists, $rules}]


evolutionDataQ[___] := False


SetSubstitutionEvolution[data_] := 0 /;
	!evolutionDataQ[data] &&
	Message[SetSubstitutionEvolution::corrupt]

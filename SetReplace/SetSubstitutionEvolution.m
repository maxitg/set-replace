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
(*Argument Checks*)


(* ::Subsection:: *)
(*Argument count*)


SetSubstitutionEvolution[args___] := 0 /;
	!Developer`CheckArgumentCount[SetSubstitutionEvolution[args], 1, 1] && False


(* ::Subsection:: *)
(*Association has correct fields*)


SetSubstitutionEvolution::corrupt =
	"SetSubstitutionEvolution does not have a correct format. " ~~
	"Use SetSubstitutionSystem for construction.";


evolutionDataQ[data_Association] := Sort[Keys[data]] =!=
	{$creatorEvents, $destroyerEvents, $generations, $atomLists, $rules}


evolutionDataQ[___] := False


SetSubstitutionSystem[data_] := 0 /;
	!evolutionDataQ[data] &&
	Message[SetSubstitutionEvolution::corrupt]


(* ::Section:: *)
(*Boxes*)


$graphIcon = Graphics[
	GraphicsComplexBox[
		{{0.1`, -3.31951456589972`},
			{-0.14816751450286603`, -2.625037331552915`},
			{0.6310524421714278`, -1.3`},
			{0.9405108616213151`, -2.8841601437046225`},
			{0.4967448863824806`, -2.092358403567382`},
			{-0.846735323402297`, -1.466588600696043`},
			{0.8846460183439665`, -0.5107506168284197`},
			{1.8939086566530445`, -2.50980168725566`},
			{1.756629266633539`, -3.4622764737192444`},
			{2.119361963550152`, -2.99`},
			{-0.5709741939515942`, -4.632295267644082`},
			{0.20977925607671288`, -4.647162049737781`},
			{-1.0861820131541373`, -4.047493574735101`},
			{-1.2223073729506904`, -2.2040562174063485`}},
		{Hue[0.6`,0.7`,0.5`],
			Opacity[0.7`],
			Arrowheads[0.`],
			ArrowBox[
				{{1, 2},
					{1, 4},
					{1, 11},
					{1, 12},
					{1, 13},
					{2, 3},
					{2, 4},
					{2, 5},
					{2, 6},
					{2, 14},
					{3, 4},
					{3, 7},
					{4, 5},
					{4, 8},
					{4, 9},
					{8, 10},
					{9, 10}},
				0.0378698213750627`],
			Hue[0.6`, 0.2`, 0.8`],
			EdgeForm[{GrayLevel[0], Opacity[0.7`]}],
			DiskBox[1, 0.05`],
			DiskBox[2, 0.05`],
			DiskBox[3, 0.05`],
			DiskBox[4, 0.05`],
			DiskBox[5, 0.05`],
			DiskBox[6, 0.05`],
			DiskBox[7, 0.05`],
			DiskBox[8, 0.05`],
			DiskBox[9, 0.05`],
			DiskBox[10, 0.05`],
			DiskBox[11, 0.05`],
			DiskBox[12, 0.05`],
			DiskBox[13, 0.05`],
			DiskBox[14, 0.05`]}],
	AspectRatio -> 1,
	Background -> GrayLevel[0.93`],
	ImagePadding -> 0,
	FrameStyle -> Directive[
		Opacity[0.5`],
		Thickness[Tiny],
		RGBColor[0.368417`, 0.506779`, 0.709798`]],
	Frame -> True,
	FrameTicks -> None,
	ImageSize -> Dynamic[{
		Automatic,
		3.5` CurrentValue["FontCapHeight"] / AbsoluteCurrentValue[Magnification]}],
	PlotRange -> {{-1.1`, 2.4`}, {-4.4`, -0.7`}}];


SetSubstitutionEvolution /:
		MakeBoxes[
			evo : SetSubstitutionEvolution[data_ ? evolutionDataQ],
			format_] := Module[
	{generationsCount, eventsCount, rules},
	generationsCount = SetSubstitutionEvolution[data]["GenerationsCount"];
	eventsCount = SetSubstitutionEvolution[data]["EventsCount"];
	rules = data[$rules];
	BoxForm`ArrangeSummaryBox[
		SetSubstitutionEvolution,
		evo,
		$graphIcon,
		(* Always grid *)
		{{BoxForm`SummaryItem[{"Generations count: ", generationsCount}]},
		{BoxForm`SummaryItem[{"Events count: ", eventsCount}]}},
		(* Sometimes grid *)
		{{BoxForm`SummaryItem[{"Rules: ", rules}]}},
		format,
		"Interpretable" -> Automatic
	]
]


(* ::Section:: *)
(*Implementation*)


$properties = {
	"Generation", "Step", "Rules", "GenerationsCount", "EventsCount",
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


$propertiesWithArguments = {"Generation", "Step"};


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


SetSubstitutionEvolution::stepTooLarge = "Step `` requested out of `` total.";


SetSubstitutionEvolution[data_ ? evolutionDataQ]["Step", s_Integer] := 0 /;
	With[{eventsCount = SetSubstitutionEvolution[data]["EventsCount"]},
		!(- eventsCount - 1 <= s <= eventsCount) &&
		Message[SetSubstitutionEvolution::stepTooLarge, s, eventsCount]]


SetSubstitutionEvolution::stepNotInteger = "Step `` must be an integer.";


SetSubstitutionEvolution[data_ ? evolutionDataQ]["Step", s_] := 0 /;
	!IntegerQ[s] &&
	Message[SetSubstitutionEvolution::stepNotInteger, s]


(* ::Subsubsection:: *)
(*Positive steps*)


SetSubstitutionEvolution[data_ ? evolutionDataQ]["Step", s_Integer] /;
		0 <= s <= SetSubstitutionEvolution[data]["EventsCount"] :=
	data[$atomLists][[Intersection[
		Position[data[$creatorEvents], _ ? (# <= s &)][[All, 1]],
		Position[data[$destroyerEvents], _ ? (# > s &)][[All, 1]]]]]


(* ::Subsubsection:: *)
(*Negative steps*)


SetSubstitutionEvolution[data_ ? evolutionDataQ]["Step", s_Integer] /;
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

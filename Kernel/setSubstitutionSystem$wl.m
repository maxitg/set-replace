(* ::Package:: *)

(* ::Title:: *)
(*setSubstitutionSystem$wl*)


(* ::Text:: *)
(*Implementation of setSubstitutionSystem in Wolfram Language. Works better with larger vertex degrees, but is otherwise much slower.*)


Package["SetReplace`"]


PackageScope["setSubstitutionSystem$wl"]


(* ::Section:: *)
(*Implementation*)


(* ::Subsection:: *)
(*toNormalRules*)


(* ::Text:: *)
(*We are going to transform set substitution rules into a list of n! normal rules, where elements of the input subset are arranged in every possible order with blank null sequences in between.*)


(* ::Text:: *)
(*This is for the case of no new vertices being created, so there is no need for a Module in the output*)


toNormalRules[input_List :> output_List] := Module[
		{inputLength, inputPermutations, heldOutput},
	inputLength = Length @ input;

	inputPermutations = Permutations @ input;
	heldOutput = Thread @ Hold @ output;

	With[{right = heldOutput},
		# :> right & /@ inputPermutations] /. Hold[expr_] :> expr
] 


(* ::Text:: *)
(*Now, if there are new vertices that need to be created, we will disassemble the Module remembering which variables it applies to, and then reassemble it for the output.*)


toNormalRules[input_List :> output_Module] := Module[
		{ruleInputOriginal = input,
		 heldModule = Map[Hold, Hold[output], {2}],
		 moduleInputContents},
	moduleInputContents = heldModule[[1, 2]];
	With[{ruleInputFinal = #[[1]],
		  moduleArguments = heldModule[[1, 1]],
		  moduleOutputContents = (Hold /@ #)[[2]]},
		ruleInputFinal :> Module[moduleArguments, moduleOutputContents]
	] & /@ toNormalRules[
			ruleInputOriginal :> Evaluate @ moduleInputContents /.
				Hold[expr_] :> expr] //.
		Hold[expr_] :> expr
]


(* ::Text:: *)
(*If there are multiple rules, we just join them*)


toNormalRules[rules_List] := Module[{
		ruleNames, separateNormalRules, longestRuleLength, untouchedNames,
		finalMatchName, input, output},
	ruleNames = Table[Unique["rule", {Temporary}], Length[rules]];
	separateNormalRules = toNormalRules /@ rules;
	longestRuleLength = Max[Map[Length, separateNormalRules[[All, All, 1]], {2}]];
	untouchedNames = Table[Unique["untouched", {Temporary}], longestRuleLength + 1];
	finalMatchName = Unique["match", {Temporary}];
	input = With[{match = finalMatchName}, List[
		match : Shortest[Alternatives @@ Catenate[Transpose @ PadRight[
			MapIndexed[
				With[{patternName = ruleNames[[#2[[1]]]]},
					Function[patternContent,
						Pattern[patternName, patternContent]] /@ #] &,
				Map[
					PatternSequence @@ If[# == {}, #, Riffle[
						#,
						Pattern[#, ___] & /@ untouchedNames,
						{1, 2 Length[#] - 1, 2}]] &,
					separateNormalRules[[All, All, 1]],
					{2}]],
			Automatic,
			nothing] /. nothing -> Nothing]],
		With[{lastPatternName = Last @ untouchedNames}, Pattern[lastPatternName, ___]]]];
	output = Hold @ Catenate @ # & @ Prepend[
		With[{ruleName = #[[1]], outputRule = #[[2]]},
			Hold[Replace[{ruleName}, outputRule]]] & /@
				Transpose[{
					ruleNames,
					With[{outputExpression = (Hold /@ #)[[2]]},
							{finalMatchName} :> outputExpression] & /@
						separateNormalRules[[All, 1]]}],
		untouchedNames];
	With[{evaluatedOutput = output}, input :> evaluatedOutput] //. Hold[expr_] :> expr
]


(* ::Subsection:: *)
(*setReplace$wl*)


(* ::Text:: *)
(*This function just does the replacements, but it does not keep track of any metadata (generations and events).*)
(*Returns {finalState, terminationReason}, and sows deleted expressions.*)


setReplace$wl[set_, rules_, stepSpec_, vertexIndex_, returnOnAbortQ_, timeConstraint_] := Module[{
		normalRules, previousResult, eventsCount = 0},
	normalRules = toNormalRules @ rules;
	previousResult = set;
	Catch[
		TimeConstrained[
			CheckAbort[
				{FixedPoint[
					AbortProtect[Module[{newResult, deletedExpressions, events},
						If[eventsCount++ == Lookup[stepSpec, $maxEvents, Infinity],
							Throw[{previousResult, $maxEvents}, $$setReplaceResult];
						];
						{newResult, {deletedExpressions, events}} = Reap[
							Catch[
								Replace[#, normalRules],
								$$reachedAtomDegreeLimit,
								Throw[{previousResult, $maxFinalVertexDegree}, $$setReplaceResult] &],
							{$$deletedExpressions, $$events}];
						If[vertexCount[vertexIndex] > Lookup[stepSpec, $maxFinalVertices, Infinity],
							Throw[{previousResult, $maxFinalVertices}, $$setReplaceResult];
						];
						If[Length[newResult] > Lookup[stepSpec, $maxFinalExpressions, Infinity],
							Throw[{previousResult, $maxFinalExpressions}, $$setReplaceResult];
						];
						Map[Sow[#, $$deletedExpressions] &, deletedExpressions, {2}];
						Map[Sow[#, $$events] &, events, {2}];
						previousResult = newResult]] &,
					List @@ set], $fixedPoint},
				If[returnOnAbortQ,
					{previousResult, $Aborted},
					Abort[]
				]],
			timeConstraint,
			If[returnOnAbortQ,
				{previousResult, $timeConstraint},
				Return[$Aborted]
			]],
		$$setReplaceResult
	]
]


(* ::Subsection:: *)
(*addMetadataManagement*)


(* ::Text:: *)
(*This function adds metadata management to the rules. I.e., the rules will not only perform the replacements, but will also keep track of generations, events, etc.*)


addMetadataManagement[
			input_List :> output_Module,
			ruleID_,
			getNextExpression_,
			maxGeneration_,
			maxVertexDegree_,
			vertexIndex_] := Module[{
		inputIDs = Table[Unique["id", {Temporary}], Length[input]],
		wholeInputPatternNames = Table[Unique["inputExpression", {Temporary}], Length[input]],
		inputGenerations = Table[Unique["generation", {Temporary}], Length[input]]},
	With[{
			heldModule = Map[Hold, Hold[output], {2}]},
		With[{
				moduleArguments = Append[
					ReleaseHold @ Map[Hold, heldModule[[1, 1]], {2}],
					With[{outputExpressionCount = Length[heldModule[[1, 2]][[1]]]},
						Hold[newExpressionIDs = Table[getNextExpression[], outputExpressionCount]]]],
				moduleOutput = heldModule[[1, 2]]},
			With[{
					newModuleContents = Join[
						(* event *)
						(* Given that these look just like normal expressions,
							which just output Nothing at the end,
							they pass just fine through all the transformation. *)
						{With[{event = {ruleID, inputIDs -> newExpressionIDs, Max[0, inputGenerations] + 1}},
							Hold[Sow[event, $$events]; Nothing]]},
						(* old expressions *)
						(* don't put them in the main set, sow them instead,
							that's much faster. *)
						With[{expr = #[[3]]},
								Hold[Sow[#, $$deletedExpressions]; deleteFromVertexIndex[vertexIndex, expr]; Nothing]] & /@
							Transpose[{
								inputIDs,
								inputGenerations,
								wholeInputPatternNames}],
						(* new expressions *)
						ReleaseHold @ MapIndexed[
							Function[
								{expr, index},
								{Hold[newExpressionIDs[[index[[-1]]]]],
								 Max[0, inputGenerations] + 1,
								 Hold[addToVertexIndex[vertexIndex, expr, maxVertexDegree]]},
								HoldAll],
							moduleOutput,
							{2}]],
					originalInput = input},
				{Pattern[Evaluate[#[[1]]], Blank[]],
				 Pattern[Evaluate[#[[2]]], Blank[]] ? (# < maxGeneration &),
				 Pattern[Evaluate[#[[4]]], #[[3]]]} & /@
						Transpose[{
							inputIDs,
							inputGenerations,
							originalInput,
							wholeInputPatternNames}] :>
					Module[moduleArguments, newModuleContents]]] //.
						Hold[expr_] :> expr]
]


(* ::Subsection:: *)
(*smallestMatchGeneration*)


$generationMetadataIndex = 2;


maxCompleteGeneration[output_, rulesNoMetadata_] := Module[{
		patternToMatch, matches},
	patternToMatch = toNormalRules[
		addMetadataManagement[#, Infinity, Infinity &, Infinity, Infinity, $noIndex] & /@ rulesNoMetadata];
	matches = Reap[
		FirstCase[
			SortBy[output, #[[$generationMetadataIndex]] &], patternToMatch, Sow[$noMatch, $$deletedExpressions], {0}],
		$$deletedExpressions][[2]];
	Switch[matches,
		{{$noMatch}},
			Infinity,
		{}, (* nothing -> something rule *)
			0,
		_,
			Max[matches[[1, All, $generationMetadataIndex]]]
	]
]


(* ::Subsection:: *)
(*setSubstitutionSystem$wl*)


(* ::Text:: *)
(*This function renames all rule inputs to avoid collisions with outputs from other rules.*)


renameRuleInputs[patternRules_] := Catch[Module[{pattern, inputAtoms, newInputAtoms},
	SetAttributes[pattern, HoldFirst];
	inputAtoms = Union[
		Quiet[
			Cases[
				# /. Pattern -> pattern,
				p : pattern[s_, rest___] :> If[MatchQ[Hold[s], Hold[_Symbol]],
					Hold[s],
					With[{originalP = p /. pattern -> Pattern}, Message[Pattern::patvar, originalP]]; Throw[$Failed]],
				All],
			{RuleDelayed::rhs}]];
	newInputAtoms = Table[Unique["inputAtom", {Temporary}], Length[inputAtoms]];
	# /. (((HoldPattern[#1] /. Hold[s_] :> s) -> #2) & @@@ Thread[inputAtoms -> newInputAtoms])
] & /@ patternRules]


(* ::Text:: *)
(*This yields unique elements in the expressions upto level 1.*)


expressionVertices[expr_] := If[ListQ[expr], Union[expr], Throw[expr, $$nonListExpression]]


(* ::Text:: *)
(*The following is used to keep track of how many times vertices appear in the set.
	All operations here should evaluate in O(1).*)


Attributes[$vertexIndex] = {HoldAll};


initVertexIndex[$vertexIndex[index_], set_] := (
	index = Merge[Association[Thread[expressionVertices[#] -> 1]] & /@ set, Total];
	set
);
initVertexIndex[$noIndex, set_] := set


deleteFromVertexIndex[$vertexIndex[index_], expr_] := ((
			index[#] = Lookup[index, Key[#], 0] - 1;
			If[index[#] == 0, KeyDropFrom[index, Key[#]]];) & /@
		expressionVertices[expr];
	expr
);
deleteFromVertexIndex[$noIndex, expr_] := expr


addToVertexIndex[$vertexIndex[index_], expr_, limit_] := ((
			index[#] = Lookup[index, Key[#], 0] + 1;
			If[index[#] > limit, Throw[#, $$reachedAtomDegreeLimit]]) & /@
		expressionVertices[expr];
	expr
);
addToVertexIndex[$noIndex, expr_, limit_] := expr


vertexCount[$vertexIndex[index_]] := Length[index]
vertexCount[$noIndex] := 0


(* ::Text:: *)
(*This function runs a modified version of the set replace system that also keeps track of metadata such as generations and events. It uses setReplace$wl to evaluate that modified system.*)


setSubstitutionSystem$wl[
			caller_, rules_, set_, stepSpec_, returnOnAbortQ_, timeConstraint_] := Module[{
		setWithMetadata, renamedRules, rulesWithMetadata, outputWithMetadata, allExpressions,
		nextExpressionID = 1, nextEventID = 1, expressionsCountsPerVertex, vertexIndex, nextExpression,
		generationsCount, maxCompleteGenerationAssumingExceedingStepSpecGenerationsDontExist},
	nextExpression = nextExpressionID++ &;
	(* {id, creator, destroyer, generation, atoms} *)
	setWithMetadata = {nextExpression[], 0, #} & /@ set;
	renamedRules = renameRuleInputs[toCanonicalRules[rules]];
	If[renamedRules === $Failed, Return[$Failed]];
	vertexIndex = If[MissingQ[stepSpec[$maxFinalVertices]] && MissingQ[stepSpec[$maxFinalVertexDegree]],
		$noIndex,
		$vertexIndex[expressionsCountsPerVertex]];
	initVertexIndex[vertexIndex, set];

	rulesWithMetadata = MapIndexed[
		addMetadataManagement[
			#,
			#2[[1]],
			nextExpression,
			Lookup[stepSpec, $maxGenerationsLocal, Infinity],
			Lookup[stepSpec, $maxFinalVertexDegree, Infinity],
			vertexIndex] &,
		renamedRules];
	outputWithMetadata = Catch[
		Reap[
			setReplace$wl[setWithMetadata, rulesWithMetadata, stepSpec, vertexIndex, returnOnAbortQ, timeConstraint],
			{$$deletedExpressions, $$events}],
		$$nonListExpression,
		(makeMessage[caller, "nonListExpressions", #];
			Return[$Failed]) &]; (* {{finalState, terminationReason}, {{deletedExpressions}, {events}}} *)
	If[outputWithMetadata[[1]] === $Aborted, Return[$Aborted]];
	allExpressions = SortBy[
		Join[
			outputWithMetadata[[1, 1]],
			If[outputWithMetadata[[2, 1]] == {}, {}, outputWithMetadata[[2, 1, 1]]]],
		First];
	initialEvent = {0, {} -> setWithMetadata[[All, 1]], 0};
	allEvents = Join[{initialEvent}, If[outputWithMetadata[[2, 2]] == {}, {}, outputWithMetadata[[2, 2, 1]]]];
	generationsCount = Max[allEvents[[All, 3]], 0];
	maxCompleteGenerationAssumingExceedingStepSpecGenerationsDontExist = CheckAbort[
		maxCompleteGeneration[outputWithMetadata[[1, 1]], renamedRules],
		If[returnOnAbortQ,
			Missing["Unknown", $Aborted],
			Return[$Aborted]
		]];

	WolframModelEvolutionObject[<|
		$version -> 2,
		$rules -> rules,
		$maxCompleteGeneration -> If[MissingQ[maxCompleteGenerationAssumingExceedingStepSpecGenerationsDontExist],
			maxCompleteGenerationAssumingExceedingStepSpecGenerationsDontExist,
			Min[maxCompleteGenerationAssumingExceedingStepSpecGenerationsDontExist, generationsCount]],
		$terminationReason -> Replace[
			outputWithMetadata[[1, 2]],
			$fixedPoint ->
				If[generationsCount == Lookup[stepSpec, $maxGenerationsLocal, Infinity],
					$maxGenerationsLocal,
					$fixedPoint]],
		$atomLists -> allExpressions[[All, 3]],
		$eventRuleIDs -> allEvents[[All, 1]],
		$eventInputs -> allEvents[[All, 2, 1]],
		$eventOutputs -> allEvents[[All, 2, 2]],
		$eventGenerations -> allEvents[[All, 3]]|>]
]

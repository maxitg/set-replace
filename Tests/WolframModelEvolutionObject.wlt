<|
  "WolframModelEvolutionObject" -> <|
    "init" -> (
      Attributes[Global`testUnevaluated] = Attributes[Global`testSymbolLeak] = {HoldAll};
      Global`testUnevaluated[args___] := SetReplace`PackageScope`testUnevaluated[VerificationTest, args];
      Global`testSymbolLeak[args___] := SetReplace`PackageScope`testSymbolLeak[VerificationTest, args];

      $largeEvolution = Hold[WolframModel[
        {{0, 1}, {0, 2}, {0, 3}} ->
          {{4, 5}, {5, 6}, {6, 4}, {4, 6}, {6, 5}, {5, 4},
          {4, 1}, {5, 2}, {6, 3},
          {1, 6}, {3, 4}},
        {{0, 0}, {0, 0}, {0, 0}},
        7]];
    ),
    "tests" -> With[{pathGraph17 = Partition[Range[17], 2, 1]}, {
      (* Symbol Leak *)

      testSymbolLeak[
        WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 5] /@ $WolframModelProperties
      ],

      (** Argument checks **)

      (* Corrupt object *)

      testUnevaluated[
        WolframModelEvolutionObject[],
        {WolframModelEvolutionObject::argx}
      ],

      testUnevaluated[
        WolframModelEvolutionObject[<||>],
        {WolframModelEvolutionObject::corrupt}
      ],

      testUnevaluated[
        WolframModelEvolutionObject[<|a -> 1, b -> 2|>],
        {WolframModelEvolutionObject::corrupt}
      ],

      (* Incorrect property arguments *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4][],
        WolframModelEvolutionObject[___][],
        {WolframModelEvolutionObject::argm},
        SameTest -> MatchQ
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["$opt$" -> 3],
        WolframModelEvolutionObject[___]["$opt$" -> 3],
        {WolframModelEvolutionObject::argm},
        SameTest -> MatchQ
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["$$$UnknownProperty$$$,,,"],
        WolframModelEvolutionObject[___]["$$$UnknownProperty$$$,,,"],
        {WolframModelEvolutionObject::unknownProperty},
        SameTest -> MatchQ
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["TotalGenerationsCount", 3],
        WolframModelEvolutionObject[___]["TotalGenerationsCount", 3],
        {WolframModelEvolutionObject::pargx},
        SameTest -> MatchQ
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["TotalGenerationsCount", 3, 3],
        WolframModelEvolutionObject[___]["TotalGenerationsCount", 3, 3],
        {WolframModelEvolutionObject::pargx},
        SameTest -> MatchQ
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["Generation", 3, 3],
        WolframModelEvolutionObject[___]["Generation", 3, 3],
        {WolframModelEvolutionObject::pargx},
        SameTest -> MatchQ
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["Generation"],
        WolframModelEvolutionObject[___]["Generation"],
        {WolframModelEvolutionObject::pargx},
        SameTest -> MatchQ
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["SetAfterEvent"],
        WolframModelEvolutionObject[___]["SetAfterEvent"],
        {WolframModelEvolutionObject::pargx},
        SameTest -> MatchQ
      ],

      (* Incorrect step arguments *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["SetAfterEvent", 16],
        WolframModelEvolutionObject[___]["SetAfterEvent", 16],
        {WolframModelEvolutionObject::stepTooLarge},
        SameTest -> MatchQ
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["SetAfterEvent", -17],
        WolframModelEvolutionObject[___]["SetAfterEvent", -17],
        {WolframModelEvolutionObject::stepTooLarge},
        SameTest -> MatchQ
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["SetAfterEvent", 1.2],
        WolframModelEvolutionObject[___]["SetAfterEvent", 1.2],
        {WolframModelEvolutionObject::stepNotInteger},
        SameTest -> MatchQ
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["SetAfterEvent", "good"],
        WolframModelEvolutionObject[___]["SetAfterEvent", "good"],
        {WolframModelEvolutionObject::stepNotInteger},
        SameTest -> MatchQ
      ],

      (* Incorrect generation arguments *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["Generation", 5],
        WolframModelEvolutionObject[___]["Generation", 5],
        {WolframModelEvolutionObject::stepTooLarge},
        SameTest -> MatchQ
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["Generation", -6],
        WolframModelEvolutionObject[___]["Generation", -6],
        {WolframModelEvolutionObject::stepTooLarge},
        SameTest -> MatchQ
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["Generation", 2.3],
        WolframModelEvolutionObject[___]["Generation", 2.3],
        {WolframModelEvolutionObject::stepNotInteger},
        SameTest -> MatchQ
      ],

      (* IncludeBoundaryEvents *)

      With[{evo = WolframModel[{{1, 2}} -> {{1, 2}}, {{1, 1}}, 1]},
        testUnevaluated[
          evo["EventsCount", "IncludeBoundaryEvents" -> $$$invalid$$$],
          {WolframModelEvolutionObject::invalidFiniteOption}
        ]
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {{1, 2}},
          {{1, 1}},
          1]["TotalGenerationsCount", "IncludeBoundaryEvents" -> #],
        1
      ] & /@ {None, "Initial", "Final", All},

      (** Boxes **)

      VerificationTest[
        Head @ ToBoxes @ WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4],
        InterpretationBox
      ],

      (** Implementation of properties **)

      (* Properties *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["Properties"],
        _List,
        SameTest -> MatchQ
      ],

      (* EvolutionObject *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["EvolutionObject"],
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]
      ],

      (* Version *)

      (* Will need to be updated with each new version. *)
      VerificationTest[
        WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, 1, Method -> #]["Version"],
        2
      ] & /@ {"LowLevel", "Symbolic"},

      (* Rules *)

      VerificationTest[
        WolframModel[
          <|"PatternRules" -> {{a_, b_}, {b_, c_}} :> {{a, c}}|>,
          pathGraph17,
          4]["Rules"],
        <|"PatternRules" -> {{a_, b_}, {b_, c_}} :> {{a, c}}|>
      ],

      VerificationTest[
        WolframModel[
          {{{1, 2}, {2, 3}} -> {{1, 3}}, {{1, 2}} -> {{1, 3}, {3, 2}}},
          pathGraph17,
          4]["Rules"],
        {{{1, 2}, {2, 3}} -> {{1, 3}}, {{1, 2}} -> {{1, 3}, {3, 2}}}
      ],

      VerificationTest[
        WolframModel[1 -> 2, {1}, 4]["Rules"],
        1 -> 2
      ],

      (* TotalGenerationsCount *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["TotalGenerationsCount"],
        4
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {},
          {{1, 2}, {2, 3}},
          2]["TotalGenerationsCount"],
        1
      ],

      (* PartialGenerationsCount *)

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {{1, 3}, {3, 2}},
          {{1, 1}},
          <|"MaxEvents" -> 30|>]["PartialGenerationsCount"],
        1
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {{1, 3}, {3, 2}},
          {{1, 1}},
          <|"MaxEvents" -> 30|>][
          "PartialGenerationsCount"],
        1
      ],

      (* CompleteGenerationsCount *)

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {{1, 3}, {3, 2}},
          {{1, 1}},
          <|"MaxEvents" -> 30|>][#],
        4
      ] & /@ {"CompleteGenerationsCount", "MaxCompleteGeneration"},

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {{1, 3}, {3, 2}},
          {{1, 1}},
          <|"MaxEvents" -> 30|>][
          "CompleteGenerationsCount"],
        4
      ],

      (* GenerationsCount *)

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {{1, 3}, {3, 2}},
          {{1, 1}},
          <|"MaxEvents" -> 30|>]["GenerationsCount"],
        {4, 1}
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {{1, 3}, {3, 2}},
          {{1, 1}},
          0]["GenerationsCount"],
        {0, 0}
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {{1, 3}, {3, 2}},
          {{1, 1}, {1, 1}},
          <|"MaxEvents" -> #|>]["GenerationsCount"] & /@ {1, 2},
        {{0, 1}, {1, 0}}
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {{1, 3}, {3, 2}},
          {{1, 1}},
          <|"MaxEvents" -> 30|>][
          "GenerationsCount"],
        {4, 1}
      ],

      (* GenerationComplete *)

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {{1, 3}, {3, 2}},
          {{1, 1}},
          <|"MaxEvents" -> 30|>]["GenerationComplete"],
        False
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {{1, 3}, {3, 2}},
          {{1, 1}},
          4]["GenerationComplete"],
        True
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {{1, 3}, {3, 2}},
          {{1, 1}},
          <|"MaxEvents" -> 30|>]["GenerationComplete", #] & /@ {-6, -5, -1, 0, 1, 4, 5, 10},
        {True, True, False, True, True, True, False, False}
      ],

      With[{evo = WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, <|"MaxEvents" -> 30|>]}, testUnevaluated[
        evo["GenerationComplete", #],
        {WolframModelEvolutionObject::stepTooLarge}
      ] & /@ {-10, -7}],

      (* EventsCount *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4][#],
        15
      ] & /@ {"EventsCount", "AllEventsCount"},

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["EventsCount", "IncludeBoundaryEvents" -> #],
        #2
      ] & @@@ {{"Initial", 16}, {"Final", 16}, {All, 17}},

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {{1, 2}},
          {{1, 1}},
          0]["EventsCount", "IncludeBoundaryEvents" -> #],
        #2
      ] & @@@ {{None, 0}, {"Initial", 1}, {"Final", 1}, {All, 2}},

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {},
          {{1, 2}, {2, 3}},
          2]["EventsCount"],
        2
      ],

      (* GenerationEventsCountList *)

      VerificationTest[
        WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 4]["GenerationEventsCountList"],
        {1, 3, 9, 27}
      ],

      VerificationTest[
        WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 0]["GenerationEventsCountList"],
        {}
      ],

      VerificationTest[
        WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 4][
          "GenerationEventsCountList", "IncludeBoundaryEvents" -> #] & /@ {None, "Initial", "Final", All},
        {{1, 3, 9, 27}, {1, 1, 3, 9, 27}, {1, 3, 9, 27, 1}, {1, 1, 3, 9, 27, 1}}
      ],

      (* GenerationEventsList *)

      VerificationTest[
        WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 2]["GenerationEventsList"],
        {{{1, {1} -> {2, 3, 4}}}, {{1, {2} -> {5, 6, 7}}, {1, {3} -> {8, 9, 10}}, {1, {4} -> {11, 12, 13}}}}
      ],

      VerificationTest[
        WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 0]["GenerationEventsList"],
        {}
      ],

      VerificationTest[
        WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 2][
          "GenerationEventsList", "IncludeBoundaryEvents" -> All],
        {
          {{0, {} -> {1}}},
          {{1, {1} -> {2, 3, 4}}},
          {{1, {2} -> {5, 6, 7}}, {1, {3} -> {8, 9, 10}}, {1, {4} -> {11, 12, 13}}},
          {{DirectedInfinity[1], {5, 6, 7, 8, 9, 10, 11, 12, 13} -> {}}}
        }
      ],

      (* VertexCountList *)

      VerificationTest[
        WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 4]["VertexCountList"],
        {1, 2, 5, 14, 41}
      ],

      VerificationTest[
        WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 0]["VertexCountList"],
        {1}
      ],

      VerificationTest[
        WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{f[1, x, y], f[1, x, y]}}, 4]["VertexCountList"],
        {1, 2, 5, 14, 41}
      ],

      (* EdgeCountList *)

      VerificationTest[
        WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 4]["EdgeCountList"],
        {1, 3, 9, 27, 81}
      ],

      VerificationTest[
        WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 0]["EdgeCountList"],
        {1}
      ],

      (* SetAfterEvent *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["SetAfterEvent", 0],
        pathGraph17
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4][#, 1],
        Join[Partition[Range[3, 17], 2, 1], {{1, 3}}]
      ] & /@ {"SetAfterEvent", "StateAfterEvent"},

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["SetAfterEvent", 2],
        Join[Partition[Range[5, 17], 2, 1], {{1, 3}, {3, 5}}]
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["SetAfterEvent", 14],
        {{1, 9}, {9, 17}}
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["SetAfterEvent", -2],
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["SetAfterEvent", 14]
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["SetAfterEvent", 15],
        {{1, 17}}
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["SetAfterEvent", -1],
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["SetAfterEvent", 15]
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {},
          {{1, 2}, {2, 3}},
          2]["SetAfterEvent", #],
        #2
      ] & @@@ {{0, {{1, 2}, {2, 3}}}, {1, {{2, 3}}}, {2, {}}},

      (* FinalState *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["FinalState"],
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["SetAfterEvent", -1]
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          0]["FinalState"],
        pathGraph17
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {},
          {{1, 2}, {2, 3}},
          2]["FinalState"],
        {}
      ],

      (* UpdatedStatesList *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["UpdatedStatesList"],
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["SetAfterEvent", #] & /@ Range[0, 15]
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          0]["UpdatedStatesList"],
        {pathGraph17}
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {},
          {{1, 2}, {2, 3}},
          2][#],
        {{{1, 2}, {2, 3}}, {{2, 3}}, {}}
      ] & /@ {"UpdatedStatesList", "AllEventsStatesList"},

      (* AllEventsStatesEdgeIndicesList *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["AllEventsStatesEdgeIndicesList"],
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["StateEdgeIndicesAfterEvent", #] & /@ Range[0, 15]
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          0]["AllEventsStatesEdgeIndicesList"],
        {Range[Length[pathGraph17]]}
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {},
          {{1, 2}, {2, 3}},
          2]["AllEventsStatesEdgeIndicesList"],
        {{1, 2}, {2}, {}}
      ],

      (* Generation *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["Generation", 0],
        pathGraph17
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["Generation", 1],
        Partition[Range[1, 17, 2], 2, 1]
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["Generation", 2],
        Partition[Range[1, 17, 4], 2, 1]
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["Generation", 3],
        {{1, 9}, {9, 17}}
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["Generation", -2],
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["Generation", 3]
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["Generation", 4],
        {{1, 17}}
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["Generation", -1],
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["Generation", 4]
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {},
          {{1, 2}, {2, 3}},
          2]["Generation", #],
        #2
      ] & @@@ {{0, {{1, 2}, {2, 3}}}, {1, {}}},

      (* StatesList *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["StatesList"],
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["Generation", #] & /@ Range[0, 4]
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          0]["StatesList"],
        {pathGraph17}
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {},
          {{1, 2}, {2, 3}},
          2]["StatesList"],
        {{{1, 2}, {2, 3}}, {}}
      ],

      (* AtomsCountFinal *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4][#],
        2
      ] & /@ {"AtomsCountFinal", "FinalDistinctElementsCount"},

      VerificationTest[
        WolframModel[
          1 -> 2,
          {1},
          5]["AtomsCountFinal"],
        1
      ],

      VerificationTest[
        WolframModel[
          1 -> 1,
          {1},
          5]["AtomsCountFinal"],
        1
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {},
          {{1, 2}, {2, 3}},
          2]["AtomsCountFinal"],
        0
      ],

      (* AtomsCountTotal *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4][#],
        17
      ] & /@ {"AtomsCountTotal", "AllEventsDistinctElementsCount"},

      VerificationTest[
        WolframModel[
          1 -> 2,
          {1},
          5]["AtomsCountTotal"],
        6
      ],

      VerificationTest[
        WolframModel[
          1 -> 1,
          {1},
          5]["AtomsCountTotal"],
        1
      ],

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {},
          {{1, 2}, {2, 3}},
          2]["AtomsCountTotal"],
        3
      ],

      (* ExpressionsCountFinal *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4][#],
        1
      ] & /@ {"ExpressionsCountFinal", "FinalEdgeCount"},

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {},
          {{1, 2}, {2, 3}},
          2]["ExpressionsCountFinal"],
        0
      ],

      (* ExpressionsCountTotal *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4][#],
        16 + 8 + 4 + 2 + 1
      ] & /@ {"ExpressionsCountTotal", "AllEventsEdgesCount"},

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {},
          {{1, 2}, {2, 3}},
          2]["ExpressionsCountTotal"],
        2
      ],

      (* CreatorEvents *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4][#],
        Join[Table[0, 16], Range[15]]
      ] & /@ {"CreatorEvents", "EdgeCreatorEventIndices"},

      (* DestroyerEvents *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4][#],
        Append[Riffle @@ ConstantArray[Range[15], 2], Infinity]
      ] & /@ {"DestroyerEvents", "EdgeDestroyerEventIndices"},

      (* EdgeDestroyerEventsIndices, lists of destroyer events *)

      VerificationTest[
        WolframModel[{{1, 2}, {2, 3}} -> {{1, 3}}, pathGraph17, 4]["EdgeDestroyerEventsIndices"],
        Append[Riffle @@ ConstantArray[List /@ Range[15], 2], {}]
      ],

      (* ExpressionGenerations *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4][#],
        Catenate[Table[Table[k, 2^(4 - k)], {k, 0, 4}]]
      ] & /@ {"ExpressionGenerations", "EdgeGenerationsList"},

      (* AllExpressions *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4][#],
        Catenate[Table[Partition[Range[1, 17, 2^k], 2, 1], {k, 0, 4}]]
      ] & /@ {"AllExpressions", "AllEventsEdgesList"},

      (* EventGenerations *)

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4][#],
        {1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 4}
      ] & /@ {"EventGenerations", "EventGenerationsList", "AllEventsGenerationsList"},

      VerificationTest[
        WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["EventGenerations", "IncludeBoundaryEvents" -> #],
        #2
      ] & @@@ {
        {"Initial", {0, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 4}},
        {"Final", {1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 4, 5}},
        {All, {0, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 4, 5}}},

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {{1, 2}},
          {{1, 1}},
          0]["EventGenerations", "IncludeBoundaryEvents" -> #],
        #2
      ] & @@@ {{None, {}}, {"Initial", {0}}, {"Final", {1}}, {All, {0, 1}}},

      VerificationTest[
        WolframModel[
          {{1, 2}} -> {},
          {{1, 2}, {2, 3}},
          2]["EventGenerations"],
        {1, 1}
      ],

      (* #258 *)
      VerificationTest[
        WolframModel[
          <|"PatternRules" -> {{{1, 2}} -> {{1, 4}}, {{1, 4}} -> {{1, 5}}, {{1, 3}} -> {{1, 6}}, {{1, 5}, {1, 6}} -> {}}|>,
          {{1, 2}, {1, 3}},
          Infinity,
          "AllEventsGenerationsList",
          "EventOrderingFunction" -> {"RuleIndex"}],
        {1, 2, 1, 3}
      ],

      (* CausalGraph *)

      Table[With[{type = type}, {
        VerificationTest[
          WolframModel[
            {{1, 2}, {2, 3}} -> {{1, 3}},
            pathGraph17,
            4][type, 1],
          WolframModelEvolutionObject[___][type, 1],
          {WolframModelEvolutionObject::nonopt},
          SameTest -> MatchQ
        ],
  
        VerificationTest[
          WolframModel[
            {{1, 2}, {2, 3}} -> {{1, 3}},
            pathGraph17,
            4][type, 1, "str" -> 3],
          WolframModelEvolutionObject[___][type, 1, "str" -> 3],
          {WolframModelEvolutionObject::nonopt},
          SameTest -> MatchQ
        ],
  
        VerificationTest[
          WolframModel[
            {{1, 2}, {2, 3}} -> {{1, 3}},
            pathGraph17,
            4][type, "BadOpt" -> "NotExist"],
          WolframModelEvolutionObject[___][type, "BadOpt" -> "NotExist"],
          {WolframModelEvolutionObject::optx},
          SameTest -> MatchQ
        ],
  
        With[{largeEvolution = $largeEvolution}, {
          VerificationTest[
            AcyclicGraphQ[ReleaseHold[largeEvolution[type]]]
          ],
  
          VerificationTest[
            LoopFreeGraphQ[ReleaseHold[largeEvolution[type]]]
          ],
  
          VerificationTest[
            Count[VertexInDegree[ReleaseHold[largeEvolution[type]]], 3],
            ReleaseHold[largeEvolution["EventsCount"]] - 1
          ],
  
          VerificationTest[
            VertexCount[ReleaseHold[largeEvolution[type]]],
            ReleaseHold[largeEvolution["EventsCount"]]
          ],
  
          VerificationTest[
            GraphDistance[ReleaseHold[largeEvolution[type]], 1, ReleaseHold[largeEvolution["EventsCount"]]],
            ReleaseHold[largeEvolution["TotalGenerationsCount"]] - 1
          ]
        }] /. HoldPattern[ReleaseHold[Hold[expr_]]] :> expr,
  
        VerificationTest[
          WolframModel[
            {{0, 1}, {0, 2}, {0, 3}} ->
              {{4, 5}, {5, 6}, {6, 4}, {4, 6}, {6, 5}, {5, 4},
              {4, 1}, {5, 2}, {6, 3},
              {1, 6}, {3, 4}},
            {{0, 0}, {0, 0}, {0, 0}},
            3,
            Method -> "Symbolic"][type],
          WolframModel[
            {{0, 1}, {0, 2}, {0, 3}} ->
              {{4, 5}, {5, 6}, {6, 4}, {4, 6}, {6, 5}, {5, 4},
              {4, 1}, {5, 2}, {6, 3},
              {1, 6}, {3, 4}},
            {{0, 0}, {0, 0}, {0, 0}},
            3,
            Method -> "LowLevel"][type]
        ],

        VerificationTest[
          Through[{VertexList, Rule @@@ EdgeList[#] &}[WolframModel[
            {{1, 2}, {2, 3}} -> {{1, 3}},
            pathGraph17,
            4][type]]],
          {Range[15],
            {1 -> 9, 2 -> 9, 3 -> 10, 4 -> 10, 5 -> 11, 6 -> 11, 7 -> 12, 8 -> 12, 9 -> 13, 10 -> 13, 11 -> 14,
              12 -> 14, 13 -> 15, 14 -> 15}}
        ],

        VerificationTest[
          Through[{VertexList, EdgeList}[WolframModel[
            {{1, 2}, {2, 3}} -> {{1, 3}},
            pathGraph17,
            1][type]]],
          {Range[8], {}}
        ],
        
        VerificationTest[
          Through[{VertexList, Rule @@@ EdgeList[#] &}[WolframModel[
            {{1, 2}, {2, 3}} -> {{1, 3}},
            Partition[Range[17], 2, 1],
            2][type]]],
          {Range[12], {1 -> 9, 2 -> 9, 3 -> 10, 4 -> 10, 5 -> 11, 6 -> 11, 7 -> 12, 8 -> 12}}
        ],

        VerificationTest[
          Through[{VertexList, Rule @@@ EdgeList[#] &}[WolframModel[
            {{1, 2}} -> {},
            {{1, 2}, {2, 3}},
            2][type]]],
          {{1, 2}, {}}
        ],

        VerificationTest[
          FilterRules[AbsoluteOptions[WolframModel[
            {{1, 2}, {2, 3}} -> {{1, 3}},
            Partition[Range[17], 2, 1],
            2][type, VertexLabels -> "Name"]], VertexLabels],
          {VertexLabels -> {"Name"}}
        ],

        VerificationTest[
          Through[{VertexList, Rule @@@ EdgeList[#] &}[WolframModel[
            {{1, 2}, {2, 3}} -> {{1, 3}},
            {{1, 2}, {2, 3}, {3, 4}, {4, 5}},
            2][type, "IncludeBoundaryEvents" -> #1]]],
          {#2, #3}
        ] & @@@ {
          {None, {1, 2, 3}, {1 -> 3, 2 -> 3}},
          {"Initial", {0, 1, 2, 3}, {0 -> 1, 0 -> 1, 0 -> 2, 0 -> 2, 1 -> 3, 2 -> 3}},
          {"Final", {1, 2, 3, Infinity}, {1 -> 3, 2 -> 3, 3 -> Infinity}},
          {All, {0, 1, 2, 3, Infinity}, {0 -> 1, 0 -> 1, 0 -> 2, 0 -> 2, 1 -> 3, 2 -> 3, 3 -> Infinity}}},

        VerificationTest[
          Through[{VertexList, Rule @@@ EdgeList[#] &}[WolframModel[
            {{1, 2}} -> {{1, 3}, {3, 2}},
            {{1, 2}},
            2][type, "IncludeBoundaryEvents" -> #1]]],
          {#2, #3}
        ] & @@@ {
          {None, {1, 2, 3}, {1 -> 2, 1 -> 3}},
          {"Initial", {0, 1, 2, 3}, {0 -> 1, 1 -> 2, 1 -> 3}},
          {"Final", {1, 2, 3, Infinity}, {1 -> 2, 1 -> 3, 2 -> Infinity, 2 -> Infinity, 3 -> Infinity, 3 -> Infinity}},
          {All,
            {0, 1, 2, 3, Infinity},
            {0 -> 1, 1 -> 2, 1 -> 3, 2 -> Infinity, 2 -> Infinity, 3 -> Infinity, 3 -> Infinity}}},

        VerificationTest[
          Through[{VertexList, Rule @@@ EdgeList[#] &}[WolframModel[
            {{1, 2}} -> {{1, 2}},
            {{1, 2}},
            0][type, "IncludeBoundaryEvents" -> #1]]],
          {#2, #3}
        ] & @@@ {
          {None, {}, {}},
          {"Initial", {0}, {}},
          {"Final", {Infinity}, {}},
          {All, {0, Infinity}, {0 -> Infinity}}}
      }], {type, {"CausalGraph", "LayeredCausalGraph"}}],

      VerificationTest[
        Round[Replace[VertexCoordinates, FilterRules[AbsoluteOptions[WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["LayeredCausalGraph"]], VertexCoordinates]][[All, 2]]],
        Floor[Log2[16 - Range[15]]]
      ],

      VerificationTest[
        Round[Replace[VertexCoordinates, FilterRules[AbsoluteOptions[WolframModel[
          {{1, 2}, {2, 3}} -> {{1, 3}},
          pathGraph17,
          4]["LayeredCausalGraph", "IncludeBoundaryEvents" -> All]], VertexCoordinates]][[All, 2]]],
        Join[{5}, Floor[Log2[16 - Range[15]]] + 1, {0}]
      ],

      VerificationTest[
        Cases[VertexStyle /. Options[
          WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, 4, #, "IncludeBoundaryEvents" -> "Initial"],
          VertexStyle][[1]], _Rule, {1}],
        {0 -> _},
        SameTest -> MatchQ
      ] & /@ {"CausalGraph", "LayeredCausalGraph"},

      VerificationTest[
        Sort[Cases[VertexStyle /. Options[
          WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, 4, "CausalGraph", "IncludeBoundaryEvents" -> #],
          VertexStyle][[1]], _Rule, {1}]],
        #2,
        SameTest -> MatchQ
      ] & @@@ {{None, {}}, {"Final", {Infinity -> _}}, {All, {0 -> _, Infinity -> _}}},

      VerificationTest[
        Options[
          WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, 4][#, EdgeStyle -> Automatic, VertexStyle -> Automatic],
          {EdgeStyle, VertexStyle}],
        Options[
          WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, 4][#],
          {EdgeStyle, VertexStyle}]
      ] & /@ {"CausalGraph", "LayeredCausalGraph"},

      VerificationTest[
        Options[
          WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, 4][
            #, EdgeStyle -> RGBColor[0.2, 0.3, 0.4], VertexStyle -> RGBColor[0.5, 0.6, 0.7]],
          {EdgeStyle, VertexStyle}],
        Options[
          Graph[
            WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, 4, #],
            EdgeStyle -> RGBColor[0.2, 0.3, 0.4],
            VertexStyle -> RGBColor[0.5, 0.6, 0.7]],
          {EdgeStyle, VertexStyle}]
      ] & /@ {"CausalGraph", "LayeredCausalGraph"},

      VerificationTest[
        Options[
          WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, 4]["LayeredCausalGraph", GraphLayout -> Automatic],
          GraphLayout],
        Options[WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, 4]["LayeredCausalGraph"], GraphLayout]
      ],

      VerificationTest[
        Options[
          WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, 4][
            "LayeredCausalGraph", GraphLayout -> "SpringElectricalEmbedding"],
          GraphLayout
        ],
        Options[
          Graph[
            WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, 4, "LayeredCausalGraph"],
            GraphLayout -> "SpringElectricalEmbedding"],
          GraphLayout]
      ],

      (* AllEventsList *)

      Table[With[{method = method}, {
        VerificationTest[
          WolframModel[{{{1}} -> {{1}}}, {{1}}, 4, Method -> method][#],
          {{1, {1} -> {2}}, {1, {2} -> {3}}, {1, {3} -> {4}}, {1, {4} -> {5}}}
        ] & /@ {"AllEventsList", "EventsList"},

        VerificationTest[
          WolframModel[{{{1}} -> {{1, 2}}, {{1, 2}} -> {{1}}}, {{1}}, 4, Method -> method]["AllEventsList"],
          {{1, {1} -> {2}}, {2, {2} -> {3}}, {1, {3} -> {4}}, {2, {4} -> {5}}}
        ],

        VerificationTest[
          WolframModel[{{{1, 2}} -> {{1}}, {{1}} -> {{1, 2}}}, {{1}}, 4, Method -> method]["AllEventsList"],
          {{2, {1} -> {2}}, {1, {2} -> {3}}, {2, {3} -> {4}}, {1, {4} -> {5}}}
        ],

        VerificationTest[
          WolframModel[{{{1, 2}} -> {{1}, {2}}, {{1}} -> {{1, 2}}}, {{1}}, 4, Method -> method]["AllEventsList"],
          {{2, {1} -> {2}}, {1, {2} -> {3, 4}}, {2, {3} -> {5}}, {2, {4} -> {6}}, {1, {5} -> {7, 8}}, {1, {6} -> {9, 10}}}
        ],

        VerificationTest[
          WolframModel[{{{1, 2}} -> {}, {{1}} -> {{1, 2}}}, {{1}}, 4, Method -> method]["AllEventsList"],
          {{2, {1} -> {2}}, {1, {2} -> {}}}
        ],

        VerificationTest[
          WolframModel[{{{1, 2}} -> {{1}}, {{1}} -> {{1, 2}}}, {{1}}, 0, Method -> method]["AllEventsList"],
          {}
        ],

        VerificationTest[
          WolframModel[
            {{{1, 2}} -> {{1}}, {{1}} -> {{1, 2}}},
            {{1}},
            4,
            Method -> method][
            "AllEventsList",
            "IncludeBoundaryEvents" -> "Initial"],
          {{0, {} -> {1}}, {2, {1} -> {2}}, {1, {2} -> {3}}, {2, {3} -> {4}}, {1, {4} -> {5}}}
        ],

        VerificationTest[
          WolframModel[
            {{{1, 2}} -> {{1}}, {{1}} -> {{1, 2}}},
            {{1}},
            4,
            Method -> method][
            "AllEventsList",
            "IncludeBoundaryEvents" -> "Final"],
          {{2, {1} -> {2}}, {1, {2} -> {3}}, {2, {3} -> {4}}, {1, {4} -> {5}}, {\[Infinity], {5} -> {}}}
        ],

        VerificationTest[
          WolframModel[
            {{{1, 2}} -> {{1}}, {{1}} -> {{1, 2}}},
            {{1}},
            4,
            Method -> method][
            "AllEventsList",
            "IncludeBoundaryEvents" -> All],
          {{0, {} -> {1}}, {2, {1} -> {2}}, {1, {2} -> {3}}, {2, {3} -> {4}}, {1, {4} -> {5}}, {\[Infinity], {5} -> {}}}
        ]
      }], {method, DeleteCases[$SetReplaceMethods, Automatic]}],

      VerificationTest[
        WolframModel[{{{1, 2}} -> {{}}, {{}} -> {{1, 2}}}, {{}}, 4]["AllEventsList"],
        {{2, {1} -> {2}}, {1, {2} -> {3}}, {2, {3} -> {4}}, {1, {4} -> {5}}}
      ],

      (* #372, event inputs should be returned in the correct order *)
      VerificationTest[
        WolframModel[{{1, 2}, {2, 3, 4}} -> {{1, 2, 3, 4}}, {{2, 3, 4}, {1, 2}}, "EventsList"],
        {{1, {2, 1} -> {3}}}
      ],

      (* EventsStatesList *)

      VerificationTest[
        WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, 2]["EventsStatesList"],
        {{{1, {1} -> {2, 3}}, {2, 3}}, {{1, {2} -> {4, 5}}, {3, 4, 5}}, {{1, {3} -> {6, 7}}, {4, 5, 6, 7}}}
      ],

      VerificationTest[
        WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, 2][
          "EventsStatesList", "IncludeBoundaryEvents" -> "Initial"],
        {
          {{0, {} -> {1}}, {1}},
          {{1, {1} -> {2, 3}}, {2, 3}},
          {{1, {2} -> {4, 5}}, {3, 4, 5}},
          {{1, {3} -> {6, 7}}, {4, 5, 6, 7}}
        }
      ],

      VerificationTest[
        WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, 2][
          "EventsStatesList", "IncludeBoundaryEvents" -> "Final"],
        {
          {{1, {1} -> {2, 3}}, {2, 3}},
          {{1, {2} -> {4, 5}}, {3, 4, 5}},
          {{1, {3} -> {6, 7}}, {4, 5, 6, 7}},
          {{DirectedInfinity[1], {4, 5, 6, 7} -> {}}, {}}
        }
      ],

      VerificationTest[
        WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, 2][
          "EventsStatesList", "IncludeBoundaryEvents" -> All],
        {
          {{0, {} -> {1}}, {1}},
          {{1, {1} -> {2, 3}}, {2, 3}},
          {{1, {2} -> {4, 5}}, {3, 4, 5}},
          {{1, {3} -> {6, 7}}, {4, 5, 6, 7}},
          {{DirectedInfinity[1], {4, 5, 6, 7} -> {}}, {}}
        }
      ]
    }]
  |>,

  "WolframModelEvolutionObjectGraphics" -> <|
    "init" -> (
      Attributes[Global`testUnevaluated] = {HoldAll};
      Global`testUnevaluated[args___] := SetReplace`PackageScope`testUnevaluated[VerificationTest, args];
      Global`checkGraphics[args___] := SetReplace`PackageScope`checkGraphics[args];
      Global`graphicsQ[args___] := SetReplace`PackageScope`graphicsQ[args];
    ),
    "tests" -> {
      (* FinalStatePlot *)

      VerificationTest[
        graphicsQ[WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 3]["FinalStatePlot"]]
      ],

      With[{evo = WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 3]}, testUnevaluated[
        evo["FinalStatePlot", "$$$invalid$$$"],
        {WolframModelEvolutionObject::nonopt}
      ]],

      With[{evo = WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 3]}, testUnevaluated[
        evo["FinalStatePlot", "$$$invalid$$$" -> 3],
        {WolframModelEvolutionObject::optx}
      ]],

      VerificationTest[
        AbsoluteOptions[
          checkGraphics @ WolframModel[
            {{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 3]["FinalStatePlot", ImageSize -> 123.],
          ImageSize],
        {ImageSize -> 123.}
      ],

      testUnevaluated[
        WolframModel[1 -> 2, {1}, 2, "FinalStatePlot"],
        {WolframModel::nonHypergraphPlot}
      ],

      With[{evo = WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, <|"MaxEvents" -> 30|>]}, testUnevaluated[
        evo["FinalStatePlot", VertexSize -> x],
        {WolframModelPlot::invalidSize}
      ]],

      (* StatesPlotsList *)

      VerificationTest[
        graphicsQ /@ WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 3]["StatesPlotsList"],
        ConstantArray[True, 4]
      ],

      With[{evo = WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 3]}, testUnevaluated[
        evo["StatesPlotsList", "$$$invalid$$$"],
        {WolframModelEvolutionObject::nonopt}
      ]],

      With[{evo = WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 3]}, testUnevaluated[
        evo["StatesPlotsList", "$$$invalid$$$" -> 3],
        {WolframModelEvolutionObject::optx}
      ]],

      VerificationTest[
        AbsoluteOptions[#, ImageSize] & /@
          checkGraphics[WolframModel[
            {{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 3]["StatesPlotsList", ImageSize -> 123.]],
        ConstantArray[{ImageSize -> 123.}, 4]
      ],

      testUnevaluated[
        WolframModel[1 -> 2, {1}, 2, "StatesPlotsList"],
        {WolframModel::nonHypergraphPlot}
      ],

      With[{evo = WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, <|"MaxEvents" -> 30|>]}, testUnevaluated[
        evo["StatesPlotsList", VertexSize -> x],
        {WolframModelPlot::invalidSize}
      ]],

      (* EventsStatesPlotsList *)

      VerificationTest[
        graphicsQ /@ WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 3]["EventsStatesPlotsList"],
        ConstantArray[True, WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 3, "EventsCount"] + 1]
      ],

      VerificationTest[
        graphicsQ /@ WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 3][
          "EventsStatesPlotsList", "IncludeBoundaryEvents" -> All],
        ConstantArray[True, WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 3, "EventsCount"] + 1]
      ],

      VerificationTest[
        graphicsQ /@ WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 0][
          "EventsStatesPlotsList", "IncludeBoundaryEvents" -> #],
        {True}
      ] & /@ {None, "Initial", "Final", All},

      With[{evo = WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 3]}, testUnevaluated[
        evo["EventsStatesPlotsList", "$$$invalid$$$"],
        {WolframModelEvolutionObject::nonopt}
      ]],

      With[{evo = WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 3]}, testUnevaluated[
        evo["EventsStatesPlotsList", "$$$invalid$$$" -> 3],
        {WolframModelEvolutionObject::optx}
      ]],

      VerificationTest[
        AbsoluteOptions[#, ImageSize] & /@
          checkGraphics @ WolframModel[
            {{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}, {{1, 1}}, 1]["EventsStatesPlotsList", ImageSize -> 123.],
        ConstantArray[{ImageSize -> 123.}, 2]
      ],

      testUnevaluated[
        WolframModel[1 -> 2, {1}, 2, "EventsStatesPlotsList"],
        {WolframModel::nonHypergraphPlot}
      ],

      With[{evo = WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, <|"MaxEvents" -> 30|>]}, testUnevaluated[
        evo["EventsStatesPlotsList", VertexSize -> x],
        {WolframModelPlot::invalidSize}
      ]],

      VerificationTest[
        graphicsQ /@ WolframModel[{{1, 2}} -> {}, {{1, 2}}, Infinity, "EventsStatesPlotsList"],
        {True, True}
      ],

      VerificationTest[
        graphicsQ /@ WolframModel[{} -> {{1, 2}}, {}, <|"MaxEvents" -> 1|>, "EventsStatesPlotsList"],
        {True, True}
      ],

      (* CausalGraph *)

      VerificationTest[
        graphicsQ @ GraphPlot[WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, 4][#, Background -> Automatic]]
      ] & /@ {"CausalGraph", "LayeredCausalGraph"},

      VerificationTest[
        Options[
          checkGraphics @ GraphPlot[
            WolframModel[{{1, 2}} -> {{1, 3}, {3, 2}}, {{1, 1}}, 4][#, Background -> RGBColor[0.2, 0.5, 0.3]]],
          Background],
        {Background -> RGBColor[0.2, 0.5, 0.3]}
      ] & /@ {"CausalGraph", "LayeredCausalGraph"}
    },
    "options" -> {
      "Parallel" -> False
    }
  |>,
  "evolutionObjectMigration" -> <|
    "init" -> (
      Attributes[Global`testUnevaluated] = {HoldAll};
      Global`testUnevaluated[args___] := SetReplace`PackageScope`testUnevaluated[VerificationTest, args];
    ),
    "tests" -> {
      (* v1 -> v2 *)
      VerificationTest[
        WolframModelEvolutionObject[<|"CreatorEvents" -> {0, 0, 0, 0, 1, 2, 3},
                                      "DestroyerEvents" -> {1, 1, 2, 2, 3, 3, Infinity},
                                      "Generations" -> {0, 0, 0, 0, 1, 1, 2},
                                      "AtomLists" -> {{1, 2}, {2, 3}, {3, 4}, {4, 5}, {1, 3}, {3, 5}, {1, 5}},
                                      "Rules" -> {{1, 2}, {2, 3}} -> {{1, 3}},
                                      "MaxCompleteGeneration" -> 2,
                                      "TerminationReason" -> "FixedPoint",
                                      "EventRuleIDs" -> {1, 1, 1}|>],
        WolframModelEvolutionObject[<|"Version" -> 2,
                                      "Rules" -> {{1, 2}, {2, 3}} -> {{1, 3}},
                                      "MaxCompleteGeneration" -> 2,
                                      "TerminationReason" -> "FixedPoint",
                                      "AtomLists" -> {{1, 2}, {2, 3}, {3, 4}, {4, 5}, {1, 3}, {3, 5}, {1, 5}},
                                      "EventRuleIDs" -> {0, 1, 1, 1},
                                      "EventInputs" -> {{}, {1, 2}, {3, 4}, {5, 6}},
                                      "EventOutputs" -> {{1, 2, 3, 4}, {5}, {6}, {7}},
                                      "EventGenerations" -> {0, 1, 1, 2}|>],
        {WolframModelEvolutionObject::migrationInputOrdering}
      ],

      (* reorder data in v1 *)
      VerificationTest[
        WolframModelEvolutionObject[<|"Rules" -> {{1, 2}, {2, 3}} -> {{1, 3}},
                                      "CreatorEvents" -> {0, 0, 0, 0, 1, 2, 3},
                                      "DestroyerEvents" -> {1, 1, 2, 2, 3, 3, Infinity},
                                      "Generations" -> {0, 0, 0, 0, 1, 1, 2},
                                      "AtomLists" -> {{1, 2}, {2, 3}, {3, 4}, {4, 5}, {1, 3}, {3, 5}, {1, 5}},
                                      "MaxCompleteGeneration" -> 2,
                                      "TerminationReason" -> "FixedPoint",
                                      "EventRuleIDs" -> {1, 1, 1}|>],
        WolframModelEvolutionObject[<|"Version" -> 2,
                                      "Rules" -> {{1, 2}, {2, 3}} -> {{1, 3}},
                                      "MaxCompleteGeneration" -> 2,
                                      "TerminationReason" -> "FixedPoint",
                                      "AtomLists" -> {{1, 2}, {2, 3}, {3, 4}, {4, 5}, {1, 3}, {3, 5}, {1, 5}},
                                      "EventRuleIDs" -> {0, 1, 1, 1},
                                      "EventInputs" -> {{}, {1, 2}, {3, 4}, {5, 6}},
                                      "EventOutputs" -> {{1, 2, 3, 4}, {5}, {6}, {7}},
                                      "EventGenerations" -> {0, 1, 1, 2}|>],
        {WolframModelEvolutionObject::migrationInputOrdering}
      ],

      (* missing keys *)
      testUnevaluated[
        WolframModelEvolutionObject[<|"Rules" -> {{1, 2}, {2, 3}} -> {{1, 3}},
                                      "CreatorEvents" -> {0, 0, 0, 0, 1, 2, 3},
                                      "DestroyerEvents" -> {1, 1, 2, 2, 3, 3, DirectedInfinity[1]},
                                      "Generations" -> {0, 0, 0, 0, 1, 1, 2},
                                      "AtomLists" -> {{1, 2}, {2, 3}, {3, 4}, {4, 5}, {1, 3}, {3, 5}, {1, 5}},
                                      "MaxCompleteGeneration" -> 2,
                                      "EventRuleIDs" -> {1, 1, 1}|>],
        {WolframModelEvolutionObject::corrupt}
      ],

      (* future version *)
      testUnevaluated[
        WolframModelEvolutionObject[<|"Version" -> 100|>],
        {WolframModelEvolutionObject::future}
      ]
    }
  |>
|>

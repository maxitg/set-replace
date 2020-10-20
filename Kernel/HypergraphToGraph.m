Package["SetReplace`"]

PackageImport["GeneralUtilities`"]

PackageExport["HypergraphToGraph"]

(* Documentation *)
HypergraphToGraph::usage = usageString[
<<<<<<< HEAD
<<<<<<< HEAD
  "HypergraphToGraph[`hg`, `method`] uses `method` to convert a hypergraph `hg` to a Graph."];

(* Options *)
Options[HypergraphToGraph] = Options[Graph];

(* SyntaxInformation *)
SyntaxInformation[HypergraphToGraph] = {
  "ArgumentsPattern" -> {_, _, OptionsPattern[]},
  "OptionNames" -> Options[HypergraphToGraph][[All, 1]]};

(* Methods *)
$validMethods = {
  "DirectedDistancePreserving",
  "StructurePreserving",
  "UndirectedDistancePreserving"};

(* Error messages *)
HypergraphToGraph::invalidMethod = StringJoin[{
  "The argument at position 2 in `1` is not ",
  Replace[ToString[#, InputForm] & /@ $validMethods, {{a__, b_} :> {Riffle[{a}, ", "], " or ", b}}],
  "."}];

(* Autocompletition *)
 With[{methods = $validMethods},
   FE`Evaluate[FEPrivate`AddSpecialArgCompletion["HypergraphToGraph" -> {0, methods}]]];

(* Argument count *)
HypergraphToGraph[args___] := 0 /;
  !Developer`CheckArgumentCount[HypergraphToGraph[args], 2, 2] && False

(* main *)
expr : HypergraphToGraph[
      hgraph_,
      method_,
      opts : OptionsPattern[]] /; recognizedOptionsQ[expr, HypergraphToGraph, {opts}] :=
  ModuleScope[
    res = Catch[hypergraphToGraph[HoldForm @ expr, hgraph, method, opts]];
    res /; res =!= $Failed
  ]

(* helper *)
graphJoin[{}, opts___] := Graph[{}, opts]
graphJoin[graphs : {__Graph}, opts___] := With[{
    vertices = Sort @ Union @ Catenate[VertexList /@ graphs],
    edges = Sort @ Catenate[EdgeList /@ graphs]},
  Graph[vertices, edges, opts]
]

(* Distance preserving *)
toDistancePreserving[{directedness_, hyperedge_}, opts___] :=
  Graph[hyperedge, directedness @@@ Subsets[hyperedge, {2}], opts]

hypergraphToGraph[
    _,
    hgraph_ ? hypergraphQ,
    method : "DirectedDistancePreserving" | "UndirectedDistancePreserving",
    opts : OptionsPattern[]] :=
  With[{directedness = Switch[method, "DirectedDistancePreserving", DirectedEdge, _, UndirectedEdge]},
    graphJoin[
      toDistancePreserving[{directedness, #}, opts] & /@ hgraph,
      opts]
  ]

(* Structure preserving *)
toStructurePreserving[{hyperedgeIndex_, {}}, opts___] :=
  Graph[{{"Hyperedge", hyperedgeIndex, 0}}, {}, opts]
toStructurePreserving[{hyperedgeIndex_, hyperedge_}, opts___] := ModuleScope[
  hyperedgeVertices = Table[
    {"Hyperedge", hyperedgeIndex, vertexPositionIndex},
    {vertexPositionIndex, 1, Length @ hyperedge}];
  vertexVertices = {"Vertex", #} & /@ hyperedge;
  Graph[
    hyperedgeVertices,
    Join[
      DirectedEdge @@@ Partition[hyperedgeVertices, 2, 1],
      Thread[DirectedEdge[hyperedgeVertices, vertexVertices]]],
    opts]
]

hypergraphToGraph[_, hgraph_ ? hypergraphQ, "StructurePreserving", opts : OptionsPattern[]] :=
  With[{
      hyperedgeGraphs = MapIndexed[toStructurePreserving[{#2[[1]], #1}, opts] &, hgraph]},
    graphJoin[
      hyperedgeGraphs,
      VertexStyle -> Replace[OptionValue[Graph, {opts}, VertexStyle],
        Automatic -> {{"Hyperedge", _, _} -> style[$lightTheme][$structurePreservingHyperedgeVertexStyle]}],
      EdgeStyle -> Replace[OptionValue[Graph, {opts}, EdgeStyle],
        Automatic -> {Rule[
          DirectedEdge[{"Hyperedge", _, _}, {"Hyperedge", _, _}],
          style[$lightTheme][$structurePreservingHyperedgeToHyperedgeEdgeStyle]]}],
      opts]
  ]
=======
  "HypergraphToGraph[`hg`] convert a hypergraph `hg` to a graph.",
  "\n",
  "HypergraphToGraph[`hg`, Method -> `method`] uses `method` for the conversion."];
=======
  "HypergraphToGraph[`hg`, `method`] converts a hypergraph `hg` to a graph by using `method`."];
>>>>>>> Moving Method option to the second argument.

(* Options *)
Options[HypergraphToGraph] = Join[{}, Options @ Graph];

(* SyntaxInformation *)
SyntaxInformation[HypergraphToGraph] = {
  "ArgumentsPattern" -> {_, _, OptionsPattern[]},
  "OptionNames" -> Options[HypergraphToGraph][[All, 1]]};

(* Argument count *)
HypergraphToGraph[args___] := 0 /;
  !Developer`CheckArgumentCount[HypergraphToGraph[args], 2, 2] && False

(* main *)
expr : HypergraphToGraph[hgraph_, method_, opts : OptionsPattern[HypergraphToGraph]] := ModuleScope[
  res = Catch[hypergraphToGraph[HoldForm @ expr, hgraph, method, opts]];
  res /; res =!= $Failed
]

(* methods *)
$validMethods = {"DistancePreserving"};

(* error messages *)
HypergraphToGraph::invalidMethod = StringJoin[{
  "The argument at position 2 in `1` is not ",
  Replace[ToString[#, InputForm] & /@ $validMethods, {{a__, b_} :> {Riffle[{a}, ", "], " or ", b}}],
  "."}];

(** Distance matrix preserving **)
hypergraphToGraph[_, hgraph_ ? hypergraphQ, "DistancePreserving", opts : OptionsPattern[]] :=
  Graph[
    vertexList @ hgraph,
    Flatten[
      Table[
        DirectedEdge[edge[[j]], edge[[i]]],
        {edge, hgraph},
        {i, Length @ edge},
        {j, i - 1}],
      2],
    FilterRules[{opts}, Options @ Graph]]

(** Structure preserving **)
>>>>>>> Adding HypergraphToGraph with Method -> "DistanceMatrix".

(* Incorrect arguments messages *)
hypergraphToGraph[expr_, hgraph_ ? (Not @* hypergraphQ), ___] :=
  (Message[HypergraphToGraph::invalidHypergraph, 1, HoldForm @ expr];
  Throw[$Failed])
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> Moving Method option to the second argument.

hypergraphToGraph[expr_, _, method_, ___] /; !MemberQ[$validMethods, method] :=
  (Message[HypergraphToGraph::invalidMethod, HoldForm @ expr];
  Throw[$Failed])
<<<<<<< HEAD
=======
>>>>>>> Adding HypergraphToGraph with Method -> "DistanceMatrix".
=======
>>>>>>> Moving Method option to the second argument.

<|
  "HypergraphToGraph" -> <|
    "init" -> (
      Attributes[Global`testUnevaluated] = {HoldAll};
      Global`testUnevaluated[args___] := SetReplace`PackageScope`testUnevaluated[VerificationTest, args];
<<<<<<< HEAD
<<<<<<< HEAD

      getVertexEdgeList[graph_?GraphQ] := Through[{VertexList, EdgeList} @ graph];
=======
>>>>>>> Adding tests for HypergraphToGraph function.
=======

      getVertexEdgeList[graph_?GraphQ] := Through[{VertexList, EdgeList} @ graph];
>>>>>>> Updating unit tests.
    ),
    "tests" -> {

      (* unevaluated *)

      (** argument count **)
      testUnevaluated[
        HypergraphToGraph[],
<<<<<<< HEAD
<<<<<<< HEAD
        {HypergraphToGraph::argrx}
=======
        {HypergraphToGraph::argx}
>>>>>>> Adding tests for HypergraphToGraph function.
=======
        {HypergraphToGraph::argrx}
>>>>>>> Fixing MessageNames in tests.
      ],

      testUnevaluated[
        HypergraphToGraph[{{1}}],
        {HypergraphToGraph::argr}
      ],

      testUnevaluated[
<<<<<<< HEAD
<<<<<<< HEAD
        HypergraphToGraph[{{1}}, "DirectedDistancePreserving", Automatic],
        {HypergraphToGraph::argrx}
      ],

      (** invalid options **)
      testUnevaluated[
        HypergraphToGraph[{{1}}, "StructurePreserving", "invalid" -> "option"],
        {HypergraphToGraph::optx}
=======
        HypergraphToGraph[{{1}}, "DistancePreserving", Automatic],
<<<<<<< HEAD
        {HypergraphToGraph::argx}
>>>>>>> Adding tests for HypergraphToGraph function.
=======
=======
        HypergraphToGraph[{{1}}, "DirectedDistancePreserving", Automatic],
>>>>>>> Updating unit tests.
        {HypergraphToGraph::argrx}
>>>>>>> Fixing MessageNames in tests.
      ],

      (** invalid options **)
      testUnevaluated[
        HypergraphToGraph[{{1}}, "StructurePreserving", "invalid" -> "option"],
        {HypergraphToGraph::optx}
      ],

      (** invalid hypergraph **)
      testUnevaluated[
<<<<<<< HEAD
<<<<<<< HEAD
        HypergraphToGraph[{1, {2}}, "DirectedDistancePreserving"],
=======
        HypergraphToGraph[{1, {2}}, "DistancePreserving"],
>>>>>>> Adding tests for HypergraphToGraph function.
=======
        HypergraphToGraph[{1, {2}}, "DirectedDistancePreserving"],
>>>>>>> Updating unit tests.
        {HypergraphToGraph::invalidHypergraph}
      ],

      (** invalid method **)
      testUnevaluated[
        HypergraphToGraph[{{2}}, "DistancePreservin"],
        {HypergraphToGraph::invalidMethod}
      ],

<<<<<<< HEAD
<<<<<<< HEAD
      (* "DirectedDistancePreserving" *)
      VerificationTest[
        HypergraphToGraph[{}, "DirectedDistancePreserving"],
        Graph[{}, {}]
      ],

      VerificationTest[
        HypergraphToGraph[{{}}, "DirectedDistancePreserving"],
        Graph[{}, {}]
      ],

      VerificationTest[
        HypergraphToGraph[{{1}}, "DirectedDistancePreserving"],
        Graph[{1}, {}]
      ],

      VerificationTest[
        HypergraphToGraph[{{1, 1}}, "DirectedDistancePreserving"],
        Graph[{1}, {DirectedEdge[1, 1]}]
      ],

      VerificationTest[
        HypergraphToGraph[{{1, 1, 1}}, "DirectedDistancePreserving"],
        Graph[{1}, {DirectedEdge[1, 1], DirectedEdge[1, 1], DirectedEdge[1, 1]}]
      ],

      VerificationTest[
        HypergraphToGraph[{{1, 2, 1}}, "DirectedDistancePreserving"],
        Graph[{1}, {DirectedEdge[1, 1], DirectedEdge[1, 2], DirectedEdge[2, 1]}]
      ],

      VerificationTest[
        HypergraphToGraph[{Range[4]}, "DirectedDistancePreserving"],
        Graph[{1, 2, 3, 4}, {1 -> 2, 1 -> 3, 1 -> 4, 2 -> 3, 2 -> 4, 3 -> 4}]
<<<<<<< HEAD
      ],

      VerificationTest[
        HypergraphToGraph[{{1, {3}, 2}, {2, 1, {3}}, {1, 1}, {2}}, "DirectedDistancePreserving"],
        Graph[{1, 2, {3}}, {1 -> 1, 1 -> 2, 1 -> {3}, 1 -> {3}, 2 -> 1, 2 -> {3}, {3} -> 2}]
      ],

      (* "UndirectedDistancePreserving" *)
      VerificationTest[
        HypergraphToGraph[{}, "UndirectedDistancePreserving"],
=======
      (* "DistancePreserving" *)
      VerificationTest[
        HypergraphToGraph[{}, "DistancePreserving"],
>>>>>>> Adding tests for HypergraphToGraph function.
=======
      (* "DirectedDistancePreserving" *)
      VerificationTest[
        HypergraphToGraph[{}, "DirectedDistancePreserving"],
>>>>>>> Updating unit tests.
        Graph[{}, {}]
      ],

      VerificationTest[
<<<<<<< HEAD
<<<<<<< HEAD
        HypergraphToGraph[{{}}, "UndirectedDistancePreserving"],
=======
        HypergraphToGraph[{{}}, "DistancePreserving"],
>>>>>>> Adding tests for HypergraphToGraph function.
=======
        HypergraphToGraph[{{}}, "DirectedDistancePreserving"],
>>>>>>> Updating unit tests.
        Graph[{}, {}]
      ],

      VerificationTest[
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
        HypergraphToGraph[{{1}}, "UndirectedDistancePreserving"],
=======
        HypergraphToGraph[{{{1}}}, "DistancePreserving"],
>>>>>>> Adding tests for HypergraphToGraph function.
=======
        HypergraphToGraph[{{1}}, "DistancePreserving"],
>>>>>>> Fixing MessageNames in tests.
=======
        HypergraphToGraph[{{1}}, "DirectedDistancePreserving"],
>>>>>>> Updating unit tests.
        Graph[{1}, {}]
      ],

      VerificationTest[
<<<<<<< HEAD
<<<<<<< HEAD
        HypergraphToGraph[{{1, 1}}, "UndirectedDistancePreserving"],
        Graph[{1}, {UndirectedEdge[1, 1]}]
      ],

      VerificationTest[
        HypergraphToGraph[{{1, 1, 1}}, "UndirectedDistancePreserving"],
        Graph[{1}, {UndirectedEdge[1, 1], UndirectedEdge[1, 1], UndirectedEdge[1, 1]}]
      ],

      VerificationTest[
        HypergraphToGraph[{{1, 2, 1}}, "UndirectedDistancePreserving"],
        Graph[{1}, {UndirectedEdge[1, 1], UndirectedEdge[1, 2], UndirectedEdge[2, 1]}]
      ],

      VerificationTest[
        HypergraphToGraph[{Range[4]}, "UndirectedDistancePreserving"],
        Graph[
          {1, 2, 3, 4},
          {1 -> 2, 1 -> 3, 1 -> 4, 2 -> 3, 2 -> 4, 3 -> 4},
          DirectedEdges -> False]
      ],

      VerificationTest[
        HypergraphToGraph[{{1, {3}, 2}, {2, 1, {3}}, {1, 1}, {2}}, "UndirectedDistancePreserving"],
        Graph[
          {1, 2, {3}},
          {1 -> 1, 1 -> 2, 1 -> {3}, 1 -> {3}, 2 -> 1, 2 -> {3}, {3} -> 2},
          DirectedEdges -> False]
      ],

      (* "StructurePreserving" *)
      VerificationTest[
        HypergraphToGraph[{}, "StructurePreserving"],
=======
        HypergraphToGraph[{{1, 1}}, "DirectedDistancePreserving"],
        Graph[{1}, {DirectedEdge[1, 1]}]
      ],

      VerificationTest[
        HypergraphToGraph[{{1, 1, 1}}, "DirectedDistancePreserving"],
        Graph[{1}, {DirectedEdge[1, 1], DirectedEdge[1, 1], DirectedEdge[1, 1]}]
      ],

      VerificationTest[
        HypergraphToGraph[{{1, 2, 1}}, "DirectedDistancePreserving"],
        Graph[{1}, {DirectedEdge[1, 1], DirectedEdge[1, 2], DirectedEdge[2, 1]}]
      ],

      VerificationTest[
        HypergraphToGraph[{Range[4]}, "DirectedDistancePreserving"],
        Graph[{1, 2, 3, 4}, {{{1, 2}, {1, 3}, {1, 4}, {2, 3}, {2, 4}, {3, 4}}, Null}]
=======
>>>>>>> Adding more unit tests.
      ],

      VerificationTest[
        HypergraphToGraph[{{1, {3}, 2}, {2, 1, {3}}, {1, 1}, {2}}, "DirectedDistancePreserving"],
        Graph[{1, 2, {3}}, {1 -> 1, 1 -> 2, 1 -> {3}, 1 -> {3}, 2 -> 1, 2 -> {3}, {3} -> 2}]
      ],

      (* "UndirectedDistancePreserving" *)
      VerificationTest[
        HypergraphToGraph[{}, "UndirectedDistancePreserving"],
>>>>>>> Updating unit tests.
        Graph[{}, {}]
      ],

      VerificationTest[
<<<<<<< HEAD
        getVertexEdgeList @ HypergraphToGraph[{{}}, "StructurePreserving"],
        getVertexEdgeList @ Graph[{{"Hyperedge", 1, 0}}, {}]
      ],

      VerificationTest[
        getVertexEdgeList @ HypergraphToGraph[{{1}}, "StructurePreserving"],
        getVertexEdgeList @ Graph[
          {{"Vertex", 1}, {"Hyperedge", 1, 1}},
          {{"Hyperedge", 1, 1} -> {"Vertex", 1}}]
      ],

      VerificationTest[
        getVertexEdgeList @ HypergraphToGraph[{{1, 1}}, "StructurePreserving"],
        getVertexEdgeList @ Graph[
          {{"Vertex", 1}, {"Hyperedge", 1, 1}, {"Hyperedge", 1, 2}},
          {
            {"Hyperedge", 1, 1} -> {"Vertex", 1},
            {"Hyperedge", 1, 1} -> {"Hyperedge", 1, 2},
            {"Hyperedge", 1, 2} -> {"Vertex", 1}}]
      ],

      VerificationTest[
        getVertexEdgeList @ HypergraphToGraph[{{1, 1, 1}}, "StructurePreserving"],
        getVertexEdgeList @ Graph[
          {
            {"Vertex", 1},
            {"Hyperedge", 1, 1},
            {"Hyperedge", 1, 2},
            {"Hyperedge", 1, 3}},
          {
            {"Hyperedge", 1, 1} -> {"Vertex", 1},
            {"Hyperedge", 1, 1} -> {"Hyperedge", 1, 2},
            {"Hyperedge", 1, 2} -> {"Vertex", 1},
            {"Hyperedge", 1, 2} -> {"Hyperedge", 1, 3},
            {"Hyperedge", 1, 3} -> {"Vertex", 1}}]
      ],

      VerificationTest[
        getVertexEdgeList @ HypergraphToGraph[{{1, 2, 1}}, "StructurePreserving"],
        getVertexEdgeList @ Graph[
          {
            {"Vertex", 1},
            {"Vertex", 2},
            {"Hyperedge", 1, 1},
            {"Hyperedge", 1, 2},
            {"Hyperedge", 1, 3}},
          {
            {"Hyperedge", 1, 1} -> {"Vertex", 1},
            {"Hyperedge", 1, 1} -> {"Hyperedge", 1, 2},
            {"Hyperedge", 1, 2} -> {"Vertex", 2},
            {"Hyperedge", 1, 2} -> {"Hyperedge", 1, 3},
            {"Hyperedge", 1, 3} -> {"Vertex", 1}}]
      ],

      VerificationTest[
        getVertexEdgeList @ HypergraphToGraph[{{x, x, y, z}, {z, w}}, "StructurePreserving"],
        getVertexEdgeList @ Graph[
          {
            {"Vertex", w},
            {"Vertex", x},
            {"Vertex", y},
            {"Vertex", z},
            {"Hyperedge", 1, 1},
            {"Hyperedge", 1, 2},
            {"Hyperedge", 1, 3},
            {"Hyperedge", 1, 4},
            {"Hyperedge", 2, 1},
            {"Hyperedge", 2, 2}},
          {
            {"Hyperedge", 1, 1} -> {"Vertex", x},
            {"Hyperedge", 1, 1} -> {"Hyperedge", 1, 2},
            {"Hyperedge", 1, 2} -> {"Vertex", x},
            {"Hyperedge", 1, 2} -> {"Hyperedge", 1, 3},
            {"Hyperedge", 1, 3} -> {"Vertex", y},
            {"Hyperedge", 1, 3} -> {"Hyperedge", 1, 4},
            {"Hyperedge", 1, 4} -> {"Vertex", z},
            {"Hyperedge", 2, 1} -> {"Vertex", z},
            {"Hyperedge", 2, 1} -> {"Hyperedge", 2, 2},
            {"Hyperedge", 2, 2} -> {"Vertex", w}}]
      ],

      (* test style*)
      With[{graph = HypergraphToGraph[{{x, x, y, z}, {z, w}}, "StructurePreserving"]},
        VerificationTest[
          !MatchQ[
            AnnotationValue[{graph, VertexList[graph, {"Hyperedge", _, _}]}, VertexStyle],
            {__Automatic}] &&
          !MatchQ[
            AnnotationValue[{graph, VertexList[graph, {"Hyperedge", _, _}]}, EdgeStyle],
            {__Automatic}],
          True
        ]
=======
        HypergraphToGraph[{Range[4]}, "DistancePreserving"],
        Graph[
          {1, 2, 3, 4},
          {
            DirectedEdge[1, 2],
            DirectedEdge[1, 3],
            DirectedEdge[2, 3],
            DirectedEdge[1, 4],
            DirectedEdge[2, 4],
            DirectedEdge[3, 4]}]
      ],

      VerificationTest[
        HypergraphToGraph[{{1, {3}, 2}, {2, 1, {3}}, {1, 1}, {2}}, "DistancePreserving"],
        Graph[
          {1, 2, {3}},
          {
            DirectedEdge[1, {3}],
            DirectedEdge[1, 2],
            DirectedEdge[{3}, 2],
            DirectedEdge[2, 1],
            DirectedEdge[2, {3}],
            DirectedEdge[1, {3}],
            DirectedEdge[1, 1]}]
>>>>>>> Adding tests for HypergraphToGraph function.
=======
        HypergraphToGraph[{{}}, "UndirectedDistancePreserving"],
        Graph[{}, {}]
      ],

      VerificationTest[
        HypergraphToGraph[{{1}}, "UndirectedDistancePreserving"],
        Graph[{1}, {}]
      ],

      VerificationTest[
        HypergraphToGraph[{{1, 1}}, "UndirectedDistancePreserving"],
        Graph[{1}, {UndirectedEdge[1, 1]}]
      ],

      VerificationTest[
        HypergraphToGraph[{{1, 1, 1}}, "UndirectedDistancePreserving"],
        Graph[{1}, {UndirectedEdge[1, 1], UndirectedEdge[1, 1], UndirectedEdge[1, 1]}]
      ],

      VerificationTest[
        HypergraphToGraph[{{1, 2, 1}}, "UndirectedDistancePreserving"],
        Graph[{1}, {UndirectedEdge[1, 1], UndirectedEdge[1, 2], UndirectedEdge[2, 1]}]
<<<<<<< HEAD
>>>>>>> Updating unit tests.
=======
      ],

      VerificationTest[
        HypergraphToGraph[{Range[4]}, "UndirectedDistancePreserving"],
        Graph[
          {1, 2, 3, 4},
          {1 -> 2, 1 -> 3, 1 -> 4, 2 -> 3, 2 -> 4, 3 -> 4},
          DirectedEdges -> False]
      ],

      VerificationTest[
        HypergraphToGraph[{{1, {3}, 2}, {2, 1, {3}}, {1, 1}, {2}}, "UndirectedDistancePreserving"],
        Graph[
          {1, 2, {3}},
          {1 -> 1, 1 -> 2, 1 -> {3}, 1 -> {3}, 2 -> 1, 2 -> {3}, {3} -> 2},
          DirectedEdges -> False]
      ],

      (* "StructurePreserving" *)
      VerificationTest[
        HypergraphToGraph[{}, "StructurePreserving"],
        Graph[{}, {}]
      ],

      VerificationTest[
        getVertexEdgeList @ HypergraphToGraph[{{}}, "StructurePreserving"],
        getVertexEdgeList @ Graph[{{"Hyperedge", 1, 0}}, {}]
      ],

      VerificationTest[
        getVertexEdgeList @ HypergraphToGraph[{{1}}, "StructurePreserving"],
        getVertexEdgeList @ Graph[
          {{"Vertex", 1}, {"Hyperedge", 1, 1}},
          {{"Hyperedge", 1, 1} -> {"Vertex", 1}}]
      ],

      VerificationTest[
        getVertexEdgeList @ HypergraphToGraph[{{1, 1}}, "StructurePreserving"],
        getVertexEdgeList @ Graph[
          {{"Vertex", 1}, {"Hyperedge", 1, 1}, {"Hyperedge", 1, 2}},
          {
            {"Hyperedge", 1, 1} -> {"Vertex", 1},
            {"Hyperedge", 1, 1} -> {"Hyperedge", 1, 2},
            {"Hyperedge", 1, 2} -> {"Vertex", 1}}]
      ],

      VerificationTest[
        getVertexEdgeList @ HypergraphToGraph[{{1, 1, 1}}, "StructurePreserving"],
        getVertexEdgeList @ Graph[
          {
            {"Vertex", 1},
            {"Hyperedge", 1, 1},
            {"Hyperedge", 1, 2},
            {"Hyperedge", 1, 3}},
          {
            {"Hyperedge", 1, 1} -> {"Vertex", 1},
            {"Hyperedge", 1, 1} -> {"Hyperedge", 1, 2},
            {"Hyperedge", 1, 2} -> {"Vertex", 1},
            {"Hyperedge", 1, 2} -> {"Hyperedge", 1, 3},
            {"Hyperedge", 1, 3} -> {"Vertex", 1}}]
      ],

      VerificationTest[
        getVertexEdgeList @ HypergraphToGraph[{{1, 2, 1}}, "StructurePreserving"],
        getVertexEdgeList @ Graph[
          {
            {"Vertex", 1},
            {"Vertex", 2},
            {"Hyperedge", 1, 1},
            {"Hyperedge", 1, 2},
            {"Hyperedge", 1, 3}},
          {
            {"Hyperedge", 1, 1} -> {"Vertex", 1},
            {"Hyperedge", 1, 1} -> {"Hyperedge", 1, 2},
            {"Hyperedge", 1, 2} -> {"Vertex", 2},
            {"Hyperedge", 1, 2} -> {"Hyperedge", 1, 3},
            {"Hyperedge", 1, 3} -> {"Vertex", 1}}]
<<<<<<< HEAD
>>>>>>> Adding more unit tests.
=======
      ],

      VerificationTest[
        getVertexEdgeList @ HypergraphToGraph[{{x, x, y, z}, {z, w}}, "StructurePreserving"],
        getVertexEdgeList @ Graph[
          {
            {"Vertex", w},
            {"Vertex", x},
            {"Vertex", y},
            {"Vertex", z},
            {"Hyperedge", 1, 1},
            {"Hyperedge", 1, 2},
            {"Hyperedge", 1, 3},
            {"Hyperedge", 1, 4},
            {"Hyperedge", 2, 1},
            {"Hyperedge", 2, 2}},
          {
            {"Hyperedge", 1, 1} -> {"Vertex", x},
            {"Hyperedge", 1, 1} -> {"Hyperedge", 1, 2},
            {"Hyperedge", 1, 2} -> {"Vertex", x},
            {"Hyperedge", 1, 2} -> {"Hyperedge", 1, 3},
            {"Hyperedge", 1, 3} -> {"Vertex", y},
            {"Hyperedge", 1, 3} -> {"Hyperedge", 1, 4},
            {"Hyperedge", 1, 4} -> {"Vertex", z},
            {"Hyperedge", 2, 1} -> {"Vertex", z},
            {"Hyperedge", 2, 1} -> {"Hyperedge", 2, 2},
            {"Hyperedge", 2, 2} -> {"Vertex", w}}]
      ],

      (* test style*)
      With[{graph = HypergraphToGraph[{{x, x, y, z}, {z, w}}, "StructurePreserving"]},
        VerificationTest[
          !MatchQ[
            AnnotationValue[{graph, VertexList[graph, {"Hyperedge", _, _}]}, VertexStyle],
            {__Automatic}] &&
          !MatchQ[
            AnnotationValue[{graph, VertexList[graph, {"Hyperedge", _, _}]}, EdgeStyle],
            {__Automatic}],
          True
        ]
>>>>>>> Updating unit tests.
      ]
    }
  |>
|>

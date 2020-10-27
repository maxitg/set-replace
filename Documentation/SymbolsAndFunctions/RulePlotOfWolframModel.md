###### [Symbols and Functions](/README.md#symbols-and-functions) >

# RulePlot of WolframModel

**`RulePlot`** can be used to get a [`WolframModelPlot`](WolframModelPlot.md)-based visual representation of hypergraph substitution rules:

```wl
In[] := RulePlot[WolframModel[{{1, 2}, {1, 2}} ->
   {{3, 2}, {3, 2}, {2, 1}, {1, 3}}]]
```

<img src="/Documentation/Images/RulePlot.png" width="429">

The shared elements between rule sides (vertices `1` and `2` in the example above) are put at the same positions in the `RulePlot` and highlighted in a darker shade of blue. Shared edges are highlighted as well:

```wl
In[] := RulePlot[WolframModel[{{1, 2, 3}} -> {{1, 2, 3}, {3, 4, 5}}]]
```

<img src="/Documentation/Images/RulePlotWithSharedEdges.png" width="429">

Multiple rules can be plotted:

```wl
In[] := RulePlot[WolframModel[{{{1, 1, 2}} ->
    {{2, 2, 1}, {2, 3, 2}, {1, 2, 3}},
   {{1, 2, 1}, {3, 4, 2}} -> {{4, 3, 2}}}]]
```

<img src="/Documentation/Images/MultipleRulesPlot.png" width="808">

Sometimes an incorrectly scaled layout might be produced due to the issue discussed above in [`VertexCoordinateRules`](WolframModelPlot.md#vertexcoordinaterules):

```wl
In[] := RulePlot[WolframModel[{{1, 2}, {1, 3}, {1, 4}} ->
   {{2, 2}, {2, 2}, {2, 5}, {3, 2}}]]
```

<img src="/Documentation/Images/IncorrectlyScaledRulePlot.png" width="429">

`VertexCoordinateRules` can be used in that case to specify the layout manually:

```wl
In[] := RulePlot[WolframModel[{{1, 2}, {1, 3}, {1, 4}} ->
   {{2, 2}, {2, 2}, {2, 5}, {3, 2}}],
 VertexCoordinateRules -> {1 -> {0, 0}, 2 -> {1, 0}, 3 -> {0, 1},
   4 -> {-1, 0}, 5 -> {2, 1}}]
```

<img src="/Documentation/Images/RulePlotWithCustomCoordinates.png" width="429">

Some of the [`WolframModelPlot`](WolframModelPlot.md) options are supported, specifically [`GraphHighlightStyle`](WolframModelPlot.md#graphhighlight-and-graphhighlightstyle), [`"HyperedgeRendering"`](WolframModelPlot.md#hyperedgerendering), [`VertexCoordinateRules`](WolframModelPlot.md#vertexcoordinaterules), [`VertexLabels`](WolframModelPlot.md#vertexlabels), [`VertexSize`, `"ArrowheadLength"`](WolframModelPlot.md#vertexsize-and-arrowheadlength), and [style options](WolframModelPlot.md#style-options). `"EdgeType"` is supported as an option instead of [the second argument](WolframModelPlot.md#edge-type) like in [`WolframModelPlot`](WolframModelPlot.md).

There are also two additional `RulePlot`-specific style options. **`Spacings`** controls the amount of empty space between the rule parts and the frame (or the space where the frame would be if it's not shown):

```wl
In[] := RulePlot[WolframModel[{{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}},
   {{1, 2}, {1, 2}} -> {{1, 3}, {3, 2}}}], Spacings -> 0.03]
```

<img src="/Documentation/Images/RulePlotWithSmallSpacings.png" width="747">

**`"RulePartsAspectRatio"`** is used to control the aspect ratio of rule sides. As an example, it can be used to force rule parts to be square:

```wl
In[] := RulePlot[WolframModel[{{1, 2}} -> {{1, 3}, {1, 3}, {3, 2}}],
 "RulePartsAspectRatio" -> 1]
```

<img src="/Documentation/Images/SquareRulePlot.png" width="429">

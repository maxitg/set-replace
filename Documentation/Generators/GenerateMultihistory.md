# GenerateMultihistory

**`GenerateMultihistory`** is the most configurable multihistory generator. With no parameters specified, it attempts to
generate all possible histories starting from the initial state. However, it can be configured to generate partial
multihistories and even single histories, although [`GenerateSingleHistory`](GenerateSingleHistory.md) is more
convenient for that.

For example, for a [`MultisetSubstitutionSystem`](/Documentation/Systems/MultisetSubstitutionSystem.md):

```wl
In[] := multihistory = GenerateMultihistory[
  MultisetSubstitutionSystem[{a_, b_} :> {a + b}], {1, 2, 3, 4}, MaxDestroyerEvents -> 3, MaxEvents -> 10]
```

<img src="/Documentation/Images/MultisetMultihistory.png" width="426.6">

```wl
In[] := #["ExpressionsEventsGraph", VertexLabels -> Placed[Automatic, After]] & @
  SetReplaceTypeConvert[WolframModelEvolutionObject] @ multihistory
```

<img src="/Documentation/Images/GenerateMultihistoryExample.png" width="478.2">

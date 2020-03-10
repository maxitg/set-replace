# Set Substitution System

## Basic Example

**SetReplace** is a [Wolfram Language](https://www.wolfram.com/language/) package to manipulate set substitution systems. To understand what a set substitution system does consider an unordered set of elements:
```
{1, 2, 5, 3, 6}
```
We can set up an operation on this set which would take any of the two elements and replace them with their sum:
```
{a_, b_} :> {a + b}
```
In **SetReplace**, this can be expressed as (the new element is put at the end)
```
In[] := SetReplace[{1, 2, 5, 3, 6}, {a_, b_} :> {a + b}]
Out[] = {5, 3, 6, 3}
```
Note that this is similar to `SubsetReplace` function of Wolfram Language (which did not exist prior to version 12.1, and which by default replaces all non-overlapping subsets at once)
```
In[] := SubsetReplace[{1, 2, 5, 3, 6}, {a_, b_} :> Sequence[a + b]]
Out[] = {3, 8, 6}
```

## Relations between Set Elements

A more interesting case (and the only case we have studied with any reasonable detail) is the case of set elements that are related to each other. Specifically, the elements can be expressed as ordered lists of atoms (or vertices), and the set essentially becomes an ordered hypergraph.

As a simple example consider a set
```
{{1, 2, 3}, {2, 4, 5}, {4, 6, 7}}
```
which we can render as a collection of ordered hyperedges:
```
In[] := HypergraphPlot[{{1, 2, 3}, {2, 4, 5}, {4, 6, 7}},
 VertexLabels -> Automatic]
```
![{{1, 2, 3}, {2, 4, 5}, {4, 6, 7}}](READMEImages/basicHypergraph.png)

We can then have a rule which would pick a subset of expressions related in a particular way (much like a join query) and replace them with something else. Note the [`Module`](https://reference.wolfram.com/language/ref/Module.html) on the right-hand side creates a new variable (vertex) which causes the hypergraph to grow.
```
{{v1_, v2_, v3_}, {v2_, v4_, v5_}} :>
 Module[{v6}, {{v5, v6, v1}, {v6, v4, v2}, {v4, v5, v3}}]
```
After a single replacement we get this (note the new vertex)
```
In[] := HypergraphPlot[
 SetReplace[{{1, 2, 3}, {2, 4, 5}, {4, 6,
    7}}, {{v1_, v2_, v3_}, {v2_, v4_, v5_}} :>
   Module[{v6}, {{v5, v6, v1}, {v6, v4, v2}, {v4, v5, v3}}]],
 VertexLabels -> Automatic]
```
![{{4, 6, 7}, {5, v1938, 1}, {v1938, 4, 2}, {4, 5, 3}}](READMEImages/basicRuleOneStep.png)

After 10 steps, we get a more complicated structure
```
In[] := HypergraphPlot[
 SetReplace[{{1, 2, 3}, {2, 4, 5}, {4, 6,
    7}}, {{v1_, v2_, v3_}, {v2_, v4_, v5_}} :>
   Module[{v6}, {{v5, v6, v1}, {v6, v4, v2}, {v4, v5, v3}}], 10],
 VertexLabels -> Automatic]
```
![{{7, 2, v1960}, {7, v1965, 6}, {v1965, v1962, 4}, {v1962, 7, v1959}, {3, v1966, v1963}, {v1966, 1, v1959}, {1, 3, v1961}, {1, v1967, v1959}, {v1967, v1963, 5}, {v1963, 1, 4}, {6, v1968, 2}, {v1968, 7, v1964}, {7, 6, v1962}}](READMEImages/basicRuleTenSteps.png)

And after 100 steps, it gets even more complicated
```
In[] := HypergraphPlot[
 SetReplace[{{1, 2, 3}, {2, 4, 5}, {4, 6,
    7}}, {{v1_, v2_, v3_}, {v2_, v4_, v5_}} :>
   Module[{v6}, {{v5, v6, v1}, {v6, v4, v2}, {v4, v5, v3}}], 100]]
```
![basicRuleHundredSteps](READMEImages/basicRuleHundredSteps.png)

Exploring the models of this more complicated variety is what this package is mostly designed for.

# Getting Started

## Prerequisites

To start using `SetReplace` you only need two things.

* [Wolfram Language 12.1+](https://www.wolfram.com/language/) including [WolframScript](https://www.wolfram.com/wolframscript/). A free (although not open-source) version is available as [Wolfram Engine](https://www.wolfram.com/engine/).
* A C++ compiler to build the low-level part of the package. Instructions on how to setup a compiler to use in WolframScript in various platforms are [available](https://reference.wolfram.com/language/CCompilerDriver/tutorial/SpecificCompilers.html#509267359).

## Build Instructions

To build,
1. `cd` to the root directory of the repository.
2. Run `./build.wls` to create the paclet file.
If you see an error message about c++17, make sure the C++ compiler you are using is up-to-date. If your default system compiler does not support c++17, you can choose a different one with environmental variables. The following, for instance, typically works on a Mac:
```
COMPILER=CCompilerDriver\`ClangCompiler\`ClangCompiler COMPILER_INSTALLATION=/usr/bin ./build.wls
```
Here `ClangCompiler` can be replaced with one of `"Compiler" /. CCompilers[Full]` (run ``<< CCompilerDriver` `` to use `CCompilers`), and `COMPILER_INSTALLATION` is a directory in which the compiler binary can be found.

3. Run `./install.wls` to install the paclet into your Wolfram system.
4. Evaluate `PacletDataRebuild[]` in all running Wolfram kernels.
5. Evaluate ``<< SetReplace` `` every time prior to using package functions.

A less frequently updated version is available through the Wolfram's public paclet server and can be installed by running `PacletInstall["SetReplace"]`.

# Symbols and Functions

## SetReplace, SetReplaceList, SetReplaceAll, SetReplaceFixedPoint and SetReplaceFixedPointList

`SetReplace` (and related `SetReplaceList`, `SetReplaceAll`, `SetReplaceFixedPoint` and `SetReplaceFixedPointList`) are the functions the package is named after. They are quite simple, don't have a lot of options, and simply perform replacement operations either one-at-a-time (as in the case of `SetReplace`), to all non-overlapping subsets (`SetReplaceAll`), or until no more matches can be made (`SetReplaceFixedPoint`). A suffix `*List` implies the function will return a set after each replacement instead of just the final result.

These functions are good for their simplicity, but we don't use them much anymore as a more advanced `WolframModel` incorporates all of these features plus other utilities helpful for the exploration of our models.

As was mentioned previously, `SetReplace` performs a single iteration if called with two arguments:
```
In[] := SetReplace[{1, 2, 5, 3, 6}, {a_, b_} :> {a + b}]
Out[] = {5, 3, 6, 3}
```

It can be supplied a third argument specifying the number of replacements (the same can be achieved using `Nest`):
```
In[] := SetReplace[{1, 2, 5, 3, 6}, {a_, b_} :> {a + b}, 2]
Out[] = {6, 3, 8}
```

If the number of replacements is set to `Infinity` calling `SetReplace` is equivalent to `SetReplaceFixedPoint`:
```
In[] := SetReplace[{1, 2, 5, 3, 6}, {a_, b_} :> {a + b}, \[Infinity]]
Out[] = {17}
```

It is possible to use multiple rules as well (here the subsets `{1, 5}` and then `{2, 6}` are replaced):
```
In[] := SetReplace[{1, 2, 5, 3,
  6}, {{a_?EvenQ, b_?EvenQ} :> {a + b}, {a_?OddQ,
    b_?OddQ} :> {a + b}}, 2]
Out[] = {3, 6, 8}
```

`SetReplaceList` can be used to see the set after each replacement (here a list is omitted on the right-hand side of the rule, which can be done if the subset only contains a single element):
```
In[] := SetReplaceList[{1, 2, 5, 3, 6}, {a_, b_} :> a + b, \[Infinity]]
Out[] = {{1, 2, 5, 3, 6}, {5, 3, 6, 3}, {6, 3, 8}, {8, 9}, {17}}
```

`SetReplaceAll` replaces all non-overlapping subsets:
```
In[] := SetReplaceAll[{1, 2, 5, 3, 6}, {a_, b_} :> a + b]
Out[] = {6, 3, 8}
```

`SetReplaceFixedPoint` and `SetReplaceFixedPointList` perform replacements for as long as possible as previously mentioned:
```
In[] := SetReplaceFixedPoint[{1, 2, 5, 3, 6}, {a_, b_} :> a + b]
Out[] = {17}
```
```
In[] := SetReplaceFixedPointList[{1, 2, 5, 3, 6}, {a_, b_} :> a + b]
Out[] = {{1, 2, 5, 3, 6}, {5, 3, 6, 3}, {6, 3, 8}, {8, 9}, {17}}

```

All of these functions have `Method`, `TimeConstraint` and `"EventOrderingFunction"` options. `TimeConstraint` is self-evident, the other two work the same way as they do in `WolframModel` and will be described further in the `WolframModel` part of this README.

## ToPatternRules

`ToPatternRules` is a convenience function used to quickly enter rules such as the one mentioned previously
```
{{v1_, v2_, v3_}, {v2_, v4_, v5_}} :>
 Module[{v6}, {{v5, v6, v1}, {v6, v4, v2}, {v4, v5, v3}}]
```

This is the type of rule we study the most, and it satisfies the following set of conditions:
* Both input and output subsets consist of (ordered) lists of atoms (aka vertices).
* The input (left-hand side) only contains patterns, it never refers to explicit vertex names.
* The name of the vertex is only used to identify it, it does not contain any additional information. As such, there are no conditions specified on the left-hand side of the rule (neither on the entire subset, nor on individual vertices), except for the implicit condition of some vertices appearing multiple times in different lists.
* The output may contain new vertices (i.e., the ones that don't appear on the left-hand side), in which case they are created with a `Module`.

`ToPatternRules` provides a simpler way to specify such rules by automatically assuming that the level-2 expressions on the left-hand side are patterns, and that vertices used on the right which don't appear on the left are new and should be created with a `Module`. For example, the rule above can simply be written as
```
In[] := ToPatternRules[{{v1, v2, v3}, {v2, v4, v5}} -> {{v5, v6, v1}, {v6, v4,
     v2}, {v4, v5, v3}}]
Out[] = {{v1_, v2_, v3_}, {v2_, v4_, v5_}} :>
 Module[{v6}, {{v5, v6, v1}, {v6, v4, v2}, {v4, v5, v3}}]
```
or even simpler as
```
In[] := ToPatternRules[{{1, 2, 3}, {2, 4, 5}} -> {{5, 6, 1}, {6, 4, 2}, {4, 5,
     3}}]
Out[] = {{v1_, v2_, v3_}, {v2_, v4_, v5_}} :>
 Module[{v6}, {{v5, v6, v1}, {v6, v4, v2}, {v4, v5, v3}}]
```

This last form of the rule is the one that we use most often, and is also the one that is accepted by `WolframModel` by default (more on that in `WolframModel` section).

`ToPatternRules` is listable in a trivial way:
```
In[] := ToPatternRules[{{{1, 2}} -> {{1, 2}, {2, 3}}, {{1, 2}} -> {{1, 3}, {3,
      2}}}]
Out[] = {{{v1_, v2_}} :> Module[{v3}, {{v1, v2}, {v2, v3}}], {{v1_, v2_}} :>
  Module[{v3}, {{v1, v3}, {v3, v2}}]}
```

## WolframModel and WolframModelEvolutionObject

`WolframModel` is the main function of the package, and provides tools for the generation and analysis of set substitution systems. It can compute many different properties of the evolution, and has many different options, which are described in the corresponding subsections.

The most basic way to call it however is this:
```
In[] := WolframModel[{{1, 2, 3}, {2, 4, 5}} -> {{5, 6, 1}, {6, 4, 2}, {4, 5,
    3}}, {{1, 2, 3}, {2, 4, 5}, {4, 6, 7}}, 10]
```
![WolframModelBasicEvolution10](READMEImages/WolframModelBasicEvolution10.png)

Note this call is different from using the `SetReplace` function in a variety of ways:
* The order of arguments is switched, the rule goes first.
* The rule is specified in the "anonymous" form (i.e., `ToPatternRules` is done implicitly).
* The number of steps here is defined the same way as in `SetReplaceAll`, which is also known as the number of generations. Here each edge can have at most 10 generations of predecessors.
* The output is not a final state, but instead an object which contains the entire evolution (similar to `SetReplaceList`) but with additional information about which rules are being used at each replacement. From the information field on that object one can see that the evolution was done for 10 generations (i.e., a fixed point has not been reached early), and 109 replacements (aka events) were made in total. More properties can be computed from an evolution object, more on that later.

To see the information an evolution object contains, let's make one with a smaller number of generations:
```
In[] := WolframModel[{{1, 2, 3}, {2, 4, 5}} -> {{5, 6, 1}, {6, 4, 2}, {4, 5,
    3}}, {{1, 2, 3}, {2, 4, 5}, {4, 6, 7}}, 3]
```
![WolframModelBasicEvolution3](READMEImages/WolframModelBasicEvolution3.png)

One can easily see its internal structure in the `InputForm`:
![WolframModelBasicEvolution3 // InputForm](READMEImages/WolframModelBasicEvolution3InputForm.png)
```
Out[] = WolframModelEvolutionObject[<|"CreatorEvents" -> {0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4,
   4, 4, 5, 5, 5}, "DestroyerEvents" -> {1, 1, 2, 3, 2, 3, 4, 4, Infinity, 5, 5,
    Infinity, Infinity, Infinity, Infinity, Infinity, Infinity, Infinity},
  "Generations" -> {0, 0, 0, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3},
  "AtomLists" -> {{1, 2, 3}, {2, 4, 5}, {4, 6, 7}, {5, 8, 1}, {8, 4, 2}, {4, 5, 3},
    {7, 9, 8}, {9, 6, 4}, {6, 7, 2}, {1, 10, 4}, {10, 8, 5}, {8, 1, 3}, {4, 11, 7},
    {11, 6, 9}, {6, 4, 8}, {5, 12, 1}, {12, 8, 10}, {8, 5, 4}},
  "Rules" -> {{1, 2, 3}, {2, 4, 5}} -> {{5, 6, 1}, {6, 4, 2}, {4, 5, 3}},
  "MaxCompleteGeneration" -> 3, "TerminationReason" -> "MaxGenerationsLocal",
  "EventRuleIDs" -> {1, 1, 1, 1, 1}|>]
```

The most important part of that association is `"AtomLists"` which includes all set elements (aka expressions or edges) ever created throughout history. Note, this does not correspond to any particular step, rather all steps are combined. They are not just catenated states as well, as if a particular expression was never used as an input for any replacement in a particular step, it would not be duplicated in that list. To see how that works, compare it to `"StatesList"` and observe that a catenated `"StatesList"` would contain more expressions than `"AtomLists"` does.
![WolframModelBasicEvolution3["StatesList"]](READMEImages/WolframModelBasicEvolution3StatesList.png)
```
Out[] = {{{1, 2, 3}, {2, 4, 5}, {4, 6, 7}}, {{4, 6, 7}, {5, 8, 1}, {8, 4,
   2}, {4, 5, 3}}, {{7, 9, 8}, {9, 6, 4}, {6, 7, 2}, {1, 10, 4}, {10,
   8, 5}, {8, 1, 3}}, {{6, 7, 2}, {8, 1, 3}, {4, 11, 7}, {11, 6,
   9}, {6, 4, 8}, {5, 12, 1}, {12, 8, 10}, {8, 5, 4}}}
```

Each edge in `"AtomLists"` has properties which are storied in other lists of the evolution object:
* `"CreatorEvents"` shows which event (aka replacement) (referenced by its index) has this edge as one of its outputs.
* `"DestroyerEvents"` shows which event has this edge as an input. Note that even though multiple matches could be possible that involve a particular edge, in the current implementation only one of these matches will be used (see `"EventOrderingFunction"` option on how to control which match to use).
* `"Generations"` shows how many layers of predecessors a given edge has.
* `"Rules"` is an exact copy of the `WolframModel` input.
* `"MaxCompleteGenerations"` shows the smallest generation such that the final state does not contain any matches composed solely of expressions from this generation. In this particular case, it is the same as the largest generation of any edge, but it might be different if a more elaborate [step specification](#step-limiters) is used.
* `"TerminationReason"` shows the reason evaluation was stopped. See the [`"TerminationReason"`](#terminationreason) property for more details.
* Finally, `"EventRuleIDs"` shows which rule was used for each event. It's rather boring in this particular case as only one rule is used in this example.

A specific property can be requested from an evolution object in a similar way as a property for an `Entity`. The list of available properties can be found [below](#properties).
![WolframModelBasicEvolution10["EventsCount"]](READMEImages/WolframModelBasicEvolution10EventsCount.png)
```
Out[] = 109
```

Some properties take additional arguments, which can be supplied after the property name:
![WolframModelBasicEvolution10["StateAfterEvent", 7]](READMEImages/WolframModelBasicEvolution10StateAfterEvent7.png)
```
Out[] = {{8, 1, 3}, {5, 12, 1}, {12, 8, 10}, {8, 5, 4}, {2, 13, 11}, {13, 7,
  6}, {7, 2, 9}, {7, 14, 6}, {14, 11, 4}, {11, 7, 8}}
```

A particular generation can be extracted simply by number (including, i.e., -1 for the final state):
![WolframModelBasicEvolution10[3]](READMEImages/WolframModelBasicEvolution10Generation3.png)
```
Out[] = {{6, 7, 2}, {8, 1, 3}, {4, 11, 7}, {11, 6, 9}, {6, 4, 8}, {5, 12,
  1}, {12, 8, 10}, {8, 5, 4}}
```

If a property does not take any arguments, it can be specified directly in `WolframModel` as a shorthand:
```
In[] := WolframModel[{{1, 2, 3}, {2, 4, 5}} -> {{5, 6, 1}, {6, 4, 2}, {4, 5,
    3}}, {{1, 2, 3}, {2, 4, 5}, {4, 6, 7}}, 10, "EdgeCountList"]
Out[] = {3, 4, 6, 8, 12, 18, 24, 36, 54, 76, 112}
```

### Rule Specification

#### Multiple Rules

Multiple rules can simply be specified as a list of rules.
```
In[] := WolframModel[{{{1, 1, 2}} -> {{2, 2, 1}, {2, 3, 2}, {1, 2, 3}}, {{1,
     2, 1}, {3, 4, 2}} -> {{4, 3, 2}}}, {{1, 1, 1}}, 4]
```
![WolframModelMultipleRulesObject](READMEImages/WolframModelMultipleRulesObject.png)

To see which rules were used for each replacement:
![WolframModelMultipleRulesObject["AllEventsRuleIndices"]](READMEImages/WolframModelMultipleRulesObjectAllEventsRuleIndices.png)
```
Out[] = {1, 1, 1, 1, 1, 1, 2, 1, 1, 1, 2, 1, 2}
```

#### Pattern Rules

Pattern rules (i.e., the kind of rules used in the `SetReplace` function) can be specified as well. As an example, previously described call to `SetReplaceList` can be reproduced as
```
In[] := WolframModel[<|"PatternRules" -> {a_, b_} :> a + b|>, {1, 2, 5, 3,
  6}, \[Infinity], "AllEventsStatesList"]
Out[] = {{1, 2, 5, 3, 6}, {5, 3, 6, 3}, {6, 3, 8}, {8, 9}, {17}}
```

### Automatic Initial State

An initial state consistint of an appropriate number of (hyper) self-loops can be automatically produced for anonymous (non-pattern) rules (here we evolve the system for 0 steps and ask the evolution object for the 0-th generation aka the initial state).
```
In[] := WolframModel[{{1, 2}, {1, 2}} -> {{3, 2}, {3, 2}, {2, 1}, {1, 3}},
  Automatic, 0][0]
Out[] = {{1, 1}, {1, 1}}
```

That even works for multiple rules in which case the loops are chosen in such a way that any of the rules can match
```
In[] := WolframModel[{{{1, 2}, {1, 2}} -> {{3, 2}, {3, 2}, {2, 1, 3}, {2,
      3}}, {{2, 1, 3}, {2, 3}} -> {{2, 1}, {1, 3}}}, Automatic, 0][0]
Out[] = {{1, 1}, {1, 1}, {1, 1, 1}}
```

Note that because different patterns can be matched to the same symbol, this initial state is guaranteed to match the rules at least once (no guarantees after that).

### Step Limiters

### Properties

### Options

## Fundamental Physics

A hypothesis is that space-time at the fundamental Planck scale might be represented as a network that can be produced by a system similar to the one this package implements.

This idea was first proposed in Stephen Wolfram's [A New Kind Of Science](https://www.wolframscience.com/nks/chap-9--fundamental-physics/).

The system here is not the same (the matching algorithm does not constrain vertex degrees), but it follows the same principles.

## C++ | Wolfram Language Implementations

There are two implementations available: one written in Wolfram Language, one in C++.

The Wolfram Language implementation permutes `SetReplace` rules in all possible ways and uses `Replace` a specified number of times to perform evolution. This works well for small graphs and small rule inputs, but it slows down with the number of edges in the graph and has exponential complexity in rule size.

The C++ implementation, on the other hand, keeps an index of all possible rule matches and updates it after every step. The reindexing algorithm looks only at the local region of the graph close to the rewrite site, thus time complexity does not depend on the graph size as long as vertex degrees are small. The downside is that it has exponential complexity (both in time and memory) in the vertex degrees. Currently, it also does not work for non-local rules (i.e., rule inputs that do not form a connected graph), although one can imagine ways to implement that.

So, in summary C++ implementation `Method -> "C++"` should be used if:
1. Vertex degrees are expected to be small.
2. Evolution needs to be done for a large number of steps `> 100`, it is possible to produce graphs with up to `10^6` edges or more.

It should not be used, however, if vertex degrees can grow large. For example
```
In[.] := SetReplace[{{0}},
  FromAnonymousRules[{{{0}} -> {{0}, {0}, {0}}, {{0}, {0}, {0}} -> {{0}}}], 30];
```
takes 3.25 seconds in C++ implementation, and less than 1 millisecond in the Wolfram Language implementation.

On the other hand, Wolfram Language implementation `Method -> "WolframLanguage"` should be used if:
1. A large number and variety of rules need to be simulated for a small number of steps.
2. Vertex degrees are expected to be large, or rules are non-local.

There are unit tests, but if you spend time studying a particular rule in detail, it is a good idea to evaluate it with both C++ and Wolfram Language implementations and check the results are the same. If results are different, create an issue, and assign `bug` and `P0` tags to it.

## Rules with Complex Behaviors

One example of an interesting system (credit to Stephen Wolfram) is
```
In[.] := GraphPlot[
 UndirectedEdge @@@
  SetReplace[{{0, 0}, {0, 0}, {0, 0}},
   FromAnonymousRules[{{0, 1}, {0, 2}, {0, 3}} -> {{4, 5}, {5, 4}, {4,
        6}, {6, 4}, {5, 6}, {6, 5}, {4, 1}, {5, 2}, {6, 3}, {1,
       6}, {3, 4}}], 10000]]
```
![First neat rule after 10,000 steps](READMEImages/neat10000.png)

A smaller system that still appears complex is
```
In[.] := GraphPlot[
 neat2 = Graph[
   DirectedEdge @@@
    SetReplace[{{0, 0}, {0, 0}, {0, 0}},
     FromAnonymousRules[{{0, 1}, {0, 2}, {0, 3}} -> {{1, 6}, {6,
         4}, {6, 5}, {5, 6}, {6, 3}, {3, 4}, {5, 2}}], 10000]]]
```
![Second neat rule after 10,000 steps](READMEImages/neatPlanar.png)

Curiously, it produces planar graphs
```
In[.] := PlanarGraphQ[neat2]
```
```
Out[.] = True
```

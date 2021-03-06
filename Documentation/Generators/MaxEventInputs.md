# MaxEventInputs

`MaxEventInputs` and [`MinEventInputs`](MinEventInputs.md) are event-selection parameters that control the maximum and
minimum numbers of input tokens allowed per event.

In addition to [being useful](MinEventInputs.md) for rules with variable numbers of inputs, `MaxEventInputs` is
sometimes useful for optimization. By default, systems like
[`MultisetSubstitutionSystem`](/Documentation/Systems/MultisetSubstitutionSystem.md) consider all subsets of tokens to
find matches, which can be slow. However, if the range of match sizes is known ahead of time, one can set it explicitly
to reduce the number of matches enumerated. Compare:

```wl
In[] := First @ AbsoluteTiming @
  GenerateMultihistory[
      MultisetSubstitutionSystem[{a___} /; Length[{a}] == 4 :> {Total[{a}]}], MaxEvents -> 20, #] @ {1, 2, 3, 4} & /@
    {{}, {MinEventInputs -> 4, MaxEventInputs -> 4}}
Out[] = {0.793215, 0.014419}
```

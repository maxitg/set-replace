Package["SetReplace`"]

PackageImport["GeneralUtilities`"]

(* TODO: fix $SetReplaceTypeGraph labels for types that are lists *)

declareTypeTranslation[
  toWolframModelEvolutionObject2, {MultisetSubstitutionSystem, 0}, {WolframModelEvolutionObject, 2}];

toWolframModelEvolutionObject2[Multihistory[_, data_]] := WolframModelEvolutionObject[<|
  "Version" -> 2,
  "Rules" -> Normal @ checkNotMissing[data["Rules"]],
  "MaxCompleteGeneration" -> Missing[],
  "TerminationReason" -> Switch[data["ConclusionReason"],
    "Terminated", "FixedPoint",
    "MaxEvents", "MaxEvents",
    _, throw[Failure["corruptMultisetMultihistory", <||>]]],
  "AtomLists" -> Normal @ checkNotMissing[data["Expressions"]],
  "EventRuleIDs" -> Normal @ checkNotMissing[data["EventRuleIndices"]],
  "EventInputs" -> Normal @ checkNotMissing[data["EventInputs"]],
  "EventOutputs" -> Normal @ checkNotMissing[data["EventOutputs"]],
  "EventGenerations" -> Normal @ checkNotMissing[data["EventGenerations"]]
|>];

declareMessage[
  General::corruptMultisetMultihistory,
  "MultisetSubstitutionSystem Multihistory is corrupt in `expr`. Use MultisetSubstitutionSystem and a generator " <>
  "function such as GenerateMultihistory to generate MultisetSubstitutionSystem Multihistory objects."];

checkNotMissing[_ ? MissingQ] := throw[Failure["corruptMultisetMultihistory", <||>]];
checkNotMissing[arg_] := arg;

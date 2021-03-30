# Type System

The basis of *SetReplace* is the type system used for [`Multihistory`](Multihistory.md) objects describing evolutions of
various computational systems.

`Multihistory` objects can be created with functions such as
[`GenerateMultihistory`](/Documentation/SymbolsAndFunctions/Generators/GenerateMultihistory.md).

These functions take various [computational systems](/Documentation/SymbolsAndFunctions/Systems/README.md) such as
[`MultisetSubstitutionSystem`](/Documentation/SymbolsAndFunctions/Systems/MultisetSubstitutionSystem.md) as an argument.

We will also have [properties]($SetReplaceProperties.md) implemented for some of these objects, e.g., `TokenEventGraph`.
These properties can transparently convert objects to the [type](/Documentation/SymbolsAndFunctions/Types/README.md)
required to evaluate them.

Most of the time, it is sufficient to rely on these automatic conversions. However, sometimes it might be useful to
convert an object to a different type manually for persistence or optimization, in which case one can use the
[`SetReplaceTypeConvert`](SetReplaceTypeConvert.md) function.

[`SetReplaceObjectQ`](SetReplaceObjectQ.md) can be used to find out if an expression is a *SetReplace* object, and
[`SetReplaceObjectType`](SetReplaceObjectType.md) can be used to determine its type.

## Helper Symbols and Functions

* Enumeration:
  * [`$SetReplaceTypes`]($SetReplaceTypes.md)
  * [`$SetReplaceProperties`]($SetReplaceProperties.md)
  * [`$SetReplaceTypeGraph`]($SetReplaceTypeGraph.md) &mdash; a graph showing translations/property implementation paths
    * Vertex heads: [`SetReplaceType`](SetReplaceType.md),
                    [`SetReplaceProperty`](SetReplaceProperty.md),
                    [`SetReplaceMethodImplementation`](SetReplaceMethodImplementation.md)
* Introspection:
  * [`SetReplaceObjectQ`](SetReplaceObjectQ.md)
  * [`SetReplaceObjectType`](SetReplaceObjectType.md)
* Conversion:
  * [`SetReplaceTypeConvert`](SetReplaceTypeConvert.md) &mdash; change an object from one type to another
* Types:
  * [`Multihistory`](Multihistory.md) &mdash; a generic kind of types for computational systems
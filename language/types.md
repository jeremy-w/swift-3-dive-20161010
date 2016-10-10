# What types can we build?

I feel like some bits of Swift's type system are kind of foggy still.
Let's look at basic de/construction abilities, and also at the name
mangling used, as that likely also reveals a decent amount about types
as they land in function args and return values.

Note that I'm using:
Apple Swift version 3.0 (swiftlang-800.0.46.2 clang-800.0.38)
AKA the one shipped with Xcode 8.0 (8A218a).

## TSPL for Swift 3: Types
https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Types.html#//apple_ref/doc/uid/TP40014097-CH31-ID445

- Named types
    - Class
    - Structure
    - Enumeration
    - Protocol
    - More…?
- Compound types (un-named):
    - Functions
    - Tuples
- Many "primitives" are structs from the stdlib.

Type grammar gives the syntax, and shows:

- array: `[T]`
- dictionary: `[K: V]`
- type identifier: `T`[`<G, …>`] or `T`[`<G, …>`]`.Identifier`
    - Note the optoinal generic argument clause there. It looks like, per the
      syntax, each dot-separated component of a type identifier can have its
      own generic arguments?!
- tuple: `(…)`
    - Each component can be named or not independently per grammar.
    - But I can see that in an assignment, you don't have to provide the
      element names, just have the types in the right order.
    - You can also still access as either `t.1` or `t.bar`.
    - And **type equality of tuples ignores the element names, too!**
      **Ditto for value equality.**
      The compiler appears to hold onto element names as part of the type name
      for the purposes of pretty-printing, but ignores it for both type and
      value equality purposes.
- function: `(`param`)` -> `return
    - This gets pretty complicated when you toss in:
        - Variadics
        - `inout`
        - `@autoclosure`
        - `@escaping`
        - `throws` and `rethrows`
            - "The throws keyword is part of a function’s type, and
              **nonthrowing functions are subtypes of throwing functions."**
            - "You can’t overload a function based only on whether the function
              can throw an error. That said, you can overload a function based
              on whether a function *parameter* can throw an error."
            - "A rethrowing function or method can contain a throw statement
              only inside a catch clause. This lets you call the throwing
              function inside a do-catch block and handle errors in the catch
              clause by throwing a different error. In addition, the catch
              clause must handle only errors thrown by one of the rethrowing
              function’s throwing parameters."
    - `->` associates to the right, so `T -> U -> V` => `T -> (U -> V)`.
- optional: `T?`
- IUO: `T!`
    - Changes the semantics of access to implicitly `!` unwrap.
      Pure sugar, basically.
    - This is forbidden from showing up anywhere other than at the outside
      of a type decl. Not in generic params, not as a tuple element type, etc.
- protocol composition type: `P & Q`
    - Anonymous composition, equivalent to `protocol GenSym: P, Q {}`
- metatype-type:
    - `NonProtocolType.Type` or `ProtocolType.Protocol`
    - **GOTCHA:** `ProtocolType.Type` refers to the type of any type conforming
      to `ProtocolType`
    - Values are created using either `T.self` for the static type
      or `type(of: instance)` for the dynamic type.
    - `===` and `!==` work for type comparisons, which allows to do
      `type(of: self) === SomeType.self`.
    - Metatypes can have initializers called on them, but the only ones
      accessible (as guaranteed to be present) are those marked `required`
      or those on a `final` class. (Otherwise, a subclass could not provide
      that initializer.)
        - This makes sense as the way people actually did inheritance in
          Obj-C, vs what you were supposed to do in terms of overriding
          the superclass's designated initializer, too. Most no-one bothered
          with that.
        - But viewed alone, it seems to break subtype polymorphism by breaking
          substitutability, so it's weird as heck when run into in practice.
- Any
- Self
    - No discussion of this here. Hmm.

**Missing are:**

- AnyObject
- Associated types
- Never
    - "Swift defines a Never type, which indicates that a function or method
      doesn’t return to its caller."
- All the C bridging sugar around function calls and returns.
    - Can we actually desugar this to understand it?
- Generics in their own right
    - "In contrast with generic types, you don’t specify a generic argument
      clause when you use a generic function or initializer. The type arguments
      are instead inferred from the type of the arguments passed to the
      function or initializer."
    - Where clauses are sugar plus the ability to add type equalities
      and constraints on types associated with the generic types themselves,
      like `T.Element: U` or `T.Element == U.Element`.

Swift type inference runs both ways, but it only happens inside a single
expression or statement.

Types can have arbitrary attributes before them as well as an optional inout.
The attribute grammar supports a lot of complex expressions with different
flavors of bracket. Quite the escape hatch for dangling new stuff on later!



### OK, Now How Do These Types Relate?
Type equality seems to get kind of weird.

Oh, reflection might have something to say on this stuff, too.

The swift/lib/Sema/ code also should capture the main language semantics.
For example, GenericTypeResolver runs into all the flavors of
genericity directly. (What's an Archetype? DependentMemberType?)

Oh! swift/docs/. SO MUCH STUFF. That's what I should be looking at.
The [TypeChecker](https://github.com/apple/swift/blob/master/docs/TypeChecker.rst) document covers Archetypes, too!

> This document describes the design and implementation of the Swift type
> checker. It is intended for developers who wish to modify, extend, or improve
> on the type checker, or simply to understand in greater depth how the Swift
> type system works.

ME ME ME!

> Archetype:
>
> An archetype constraint requires that the constrained type be bound to an
> archetype. This is a very specific kind of constraint that is only used
> for calls to operators in protocols.

That still doesn't define "archetype". Harrumph.

Searched the bug tracker.
https://bugs.swift.org/browse/SR-617?jql=text%20~%20%22archetype%22 makes it
sound like the Self type is an archetype. I suspect any of the existential
associatedtypes are also archetypes, but I'm not sure.

And listservs scares up very little too, basically just:
https://lists.swift.org/pipermail/swift-dev/Week-of-Mon-20151207/000302.html

> Note that this immediate opening of generic function types is only valid
> because Swift does not support first-class polymorphic functions, e.g., one
> cannot declare a variable of type `<T> T -> T`.
> (https://github.com/apple/swift/blob/master/docs/TypeChecker.rst#polymorphic-types)

- So many implicit conversions/subtyping relationships!
- Function application vs construction are treated differently but look
  pretty much the same to the compiler, so might invite bugs.
- Pretty much no coverage in this doc of protocols, though.

That parametric polymorphic types aren't first-class is surely interesting,
though.

> Associated types are similar to type parameters in generic parameter clauses,
> but they’re associated with Self in the protocol in which they’re declared.
> In that context, Self refers to the eventual type that conforms to the
> protocol. (https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Declarations.html#//apple_ref/doc/uid/TP40014097-CH34-ID374)

Huh - the binding for an associated type can be inferred:

> Thanks to Swift’s type inference, you don’t actually need to declare
> a concrete ItemType of Int as part of the definition of IntStack. Because
> IntStack conforms to all of the requirements of the Container protocol, Swift
> can infer the appropriate ItemType to use, simply by looking at the type of
> the `append(_:)` method’s item parameter and the return type of the
> subscript. Indeed, if you delete the typealias ItemType = Int line from the
> code above, everything still works, because it is clear what type should be
> used for ItemType. (https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Generics.html#//apple_ref/doc/uid/TP40014097-CH26-ID189)

And you can rendezvous generics and associated types by conforming a generic
type to a protocol with associated types. So that means that we can vend
an instance meeting the protocol requirements given whatever generic types
someone wants to give us - "forall T, there exists U such that U conforms to P"
kind of situation.

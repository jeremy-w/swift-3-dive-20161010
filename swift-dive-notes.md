# Dive into Swift
- Unconference: Week of 10th October 2016
- Jeremy W. Sherman
- Charter: https://goo.gl/ERUan5 (private docco for my reference)
- Requirement: Produce 3 blog posts within 90 days of conclusion.


## 2016-10-10 (Mon)
The plan for this week:

- Up front: Capture questions I want answered
- Repeatedly:
    - Pick the question annoying me the most or the most useful
    - Crack it

Today:

- Reviewed the type grammar and reference in The Swift Programming Language.
- Found the typechecker docs in the Swift repo itself and read through those.
    - ???: What the heck is an archetype? Shows up all over in the
      compiler source, mentioned in then typechecker doc, defined NOWHERE!
- Refined my understanding of some of Swift's more detailed bits and bobs
  (inheritance, tuple types, default values, generics).
- Inadvertently answered my "why is `- seealso:` broken in Quick Help?"
  question: It's now `- see:` per the RNG schema
  [here](https://github.com/apple/swift/blob/master/bindings/xml/comment-xml-schema.rng#L775).

Questions answered today are from the LANGUAGE grouping.

- Language:
    - [What types can we build?](language/types.md)
        - Edge case: "if you apply both a prefix and a postfix operator to the
          same operand, the postfix operator is applied first."
    - How exactly does inheritance operate? (`required init`)
        - Initializers don't propagate down to subtypes unless `required`.
          Whatever initializer the subtype adds _does_ have to chain up
          to one in the superclass, though.
        - Fillip: You can inherit initializers (including convenience)
          as long as you don't add your own designated init, OR you
          implement all the superclass's designated inits (which means
          the superclass's convenience inits conveniently hit one
          of your overridden inits for sure).
            - This gets triggered a lot in practice.
            - ???: Does having an `NSObject` in the inheritance hierarchy
              suddenly mean that Obj-C-y inheritance rules come into play?
        - Final can be applied, not just to the class as a whole,
          but also just to specific methods/properties/subcripts.
          Including if they're added via an extension.
        - Subclasses do NOT get a crack at constant properties of their
          superclasses.
        - Ooh, workaround for annoyance:

          > If you want your custom value type to be initializable with the
          > default initializer and memberwise initializer, and also with your
          > own custom initializers, write your custom initializers in an
          > extension rather than as part of the value type’s original
          > implementation.
        - `case let foo as Thing` is a kind of cast I forgot existed.
          I think I also tend to forget about `where` clauses on cases.
    - How should we think about default args, especially if you want to
      un-default the second but not the first?
        - I had a `init(foo: Foo = Foo(), bar: Bar = Bar())`
          and wanted to invoke with a custom `Bar`, so did
          `init(bar: BarBazzle)`. The compiler then yelled that it expected
          `foo` and what was I trying to pull?
        - You can't skip them like Python - if they're not present, they're
          defaulted, but otherwise, they have to be present, in order.
          So order of arguments when you plan to default matters.
    - What is just sugar, vs what's essential?
        - Not a ton of sugar. Function types get pretty complicated.
    - What can we destructure, and where?
        - See [Patterns](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/Patterns.html#//apple_ref/doc/uid/TP40014097-CH36-ID419)
        - Two classes in intro section, but really, three in truth:
            - Limited, with simple variable/constant/optional binding or
              wildcard (`_`). Can limit it a bit with type annotation;
              this is how we flow type info back from the decl to the literal
              in `let x: UInt8 = 3`.
              **Tuple bindings are fair game here, though!**
            - Full pattern matching, which is done at runtime and can fail,
              is used with `switch/case`, `do/catch`, and
              `if/while/guard/for-in case`.
            - Overridable match-operator `~=` pattern matching, available
              only in `switch/case` per the book.
        - **Case exhaustiveness is kind of derpy.**
          I used Python to generate an exhaustive identity function for `UInt8`
          - one case for each of 0 through 255 - and still got the "consider
            a default" error. See [exhaustive-uint8.swift][].
        - Constant declarations are identifier pattern matches.
          So you can do `let (a, b) = (1, 2)` to define `a` and `b`.
            - Identical to 1-tuple patterns, too:

              > The parentheses around a tuple pattern that contains a single
              > element have no effect. The pattern matches values of that
              > single element’s type.
        - NOTE: Swift docs language now calls let-bound names "constants" and
          var-bound names "variables".
        - Nice trick: `for case let x? in Xs` instead of
          `for x in Xs { guard let reallyX = x else { continue }`.
        - Expression patterns are only valid in `switch-case` and use


### Questions
- Language:
    - What does the "AnyFoo" type-erasure trick _mean,_ and how does it really
      work?
    - What are the semantics around value capture in a closure?
      What happens when you have racing around a closure, or change a captured
      value after creating the closure?
    - Type aliases can have their access controlled separately from the
      thing they alias. How does extending a type alias impact the access
      level of things in that extension?

- Stdlib:
    - Become familiar with its many protocols, particularly those related to
      collections
        - **Produce a one-line "the gist of this protocol" for each.**
    - How does lazy work, and what's the impact?
    - What about slices and contiguous arrays?

- Community:
    - How does open source Swift work, how is it organized, and who's involved?
    - What's up with the package manager?
        - An intro to this might be useful if there's not already a good one
          out there.

- Debugging/Implementation/Perf:
    - What does disassembled Swift look like?
        - Common prolog
        - Common postlog
        - Common retain count operations
        - Interacting with generics, protocols, closures
        - Register usage and argument and return value passing conventions
            - I know these aren't locked down yet, because no stable ABI.
    - How would I call a Swift function if `expr`'s Swift support went
      haywire?
    - How would I set a symbolic breakpoint for retain on a Swift class?
      And does that even make sense?
    - What sort of output does the compiler spit out? What does my code
      generate at the compiled level?
    - How are protocols implemented?
    - How does cross-module interaction work?
    - What effect do access controls have on the compiled binary?
        - Compiler aside, protocols are kind of weird around access control,
          with a lot of against-the-grain behaviors, like members having
          the same public access level as a public protocol.
    - What's up with SIL, and can I do useful things with it programmatically?
        - This could become a rabbit hole very quickly.
    - What can you do to speed things up? What are surprising losses of speed
      at runtime? How would you recognize it in a profile to know it matters?

- Unsafe Swift:
    - Can we write out a desugaring for all the bridging business to better
      understand its elements?
    - How do we do the stuff we do in Obj/C with Swift?
        - Read MarkD's AdviOS content on this. He may already have sorted all
          this out!
    - What are the memory, concurrency, retain, etc. implications of various
      manipulations?
    - Where do we wander into undefined Swift behavior?
    - Why does everything go insane and into the weeds when I try to pass
      a dictionary literal as-is into `SecAddItem`, but if I declare the
      dictionary as `: NSDictionary`, suddenly everything is hunky-dory?


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


## 2016-10-11 (Tues)
- Poked at enums and exhaustiveness and raw values a bit. The raw assignment
  really is pretty braindead. This is a good move in terms of predictability
  and mental modeling, so, I like it.
- Investigated Swift + Obj-C usage without an xcodeproj.
  Figured out how to do it, as well as came to a better understanding of
  what Xcode is doing to compile combined Swift + Obj-C projects.
    - Do note that I only looked at the "all in the same module" case;
      I haven't looked into cross-module uses, either Swift–Swift or
      Swift–Obj-C.
- Learned that Swift defends its initializer inheritance rules at runtime
  if called into from Obj-C. Ouch.
- Sussed out the AnyFoo protocol => generic type erasure dealy.


Questions answered today:

- Language:
    - Does having an `NSObject` in the inheritance hierarchy suddenly mean that
      Obj-C-y initializer inheritance rules come into play?
      Or are those just always in play, but only from Obj-C code, if you're
      calling into a Swift hierarchy from Obj-C?
        - They're visible still from Obj-C, but not from Swift.
          This is made clear by the generated header if you use
          `-emit-objc-header` with `swiftc`. It dumps out a line in the
          interface for a class like:

          ```objc
          - (nonnull instancetype)init SWIFT_UNAVAILABLE;
          ```
        - If called from Obj-C, even though in the header, they will explode
          with a fatal error about an unimplemented initializer at runtime.
          Fun fun! So, uh, don't do that.
    - What does the "AnyFoo" type-erasure trick _mean,_ and how does it really
      work?
        - It substitutes subtype polymorphism for parametric polymorphism.


### Exhaustiveness Games
- Swift fails to note exhaustiveness of a switch over UInt8.
- More edge case funz to try today:
    - What happens if I make an enum backed by UInt8 with more than 256 cases?
        - Overflow error
    - What if I make an enum backed by Int8 with more than 128 cases - does it
      start using negative numbers as the raw value eventually?
        - Overflow error
    - If I make a non-raw enum with 256 cases and switch/case over it,
      does it correctly identify it as exhaustive, or does it just flip out
      past a certain number?
        - A-OK


#### More Cases Than Raw Values: Error
uint8-enum-256-cases.swift

```python
s = "enum TooBig: UInt8 {\n" + "\n".join(["    case {0}".format("value" + str(i)) for i in range(0, 257)]) + "\n}\n"
file("uint8-enum-257-cases.swift", 'w').write(s)
```

Error emitted twice (???), but correctly handled:

```
> swift uint8-enum-257-cases.swift
uint8-enum-257-cases.swift:258:10: error: integer literal '256' overflows when stored into 'UInt8'
    case value256
         ^
uint8-enum-257-cases.swift:258:10: error: integer literal '256' overflows when stored into 'UInt8'
    case value256
         ^
```


#### Signed Overflow: Error
```python
s = "enum Overflows: Int8 {\n" + "\n".join(["    case {0}".format("value" + str(i)) for i in range(0, 256)]) + "\n}\n"
file("int8-enum-256-cases.swift", 'w').write(s)
```

Double output again, this time counting down from 256 to 128 and then again.
Errors look like:

```
int8-enum-256-cases.swift:130:10: error: integer literal '128' overflows when stored into 'Int8'
    case value128
         ^
```

So, it simply counts up, then tries to store into the backing value.
Nothing clever.


#### My Own UInt8 Exhaustiveness Check: A-OK
```python
s = "enum ManyCases{\n" + "\n".join(["    case {0}".format("value" + str(i)) for i in range(0, 256)]) + "\n\n"
s += "var uint8: UInt8 {\n  switch self {\n" + "\n".join(["    case .{0}: return {1}".format("value" + str(i), i) for i in range(0, 256)]) + "\n}\n}\n"
s += "}\n"
file("my-256-case-enum-exhaustiveness.swift", 'w').write(s)
```

Compiles just fine.


### How do we hand-compile an Obj-C file linking against Swift?
Say we write a standalone Swift file `Foo.swift`.

We can build it with:

    xcrun -sdk macosx10.12 swiftc -emit-module -emit-objc-header Foo.swift -module-name Foo

and get:

- Foo.swiftmodule
- Foo.h

Now say we want to `@import Foo` from `UsesFoo.m`. What do we need to do?

#### What Xcode Does
If you add an Obj-C file to a Swift project, it sets `CLANG_ENABLE_MODULES=YES`
(so `-fmodules`) and `SWIFT_OBJC_BRIDGING_HEADER`.

- What does `SWIFT_OBJC_BRIDGING_HEADER` change about compilation?
    - Xcode uses `swift -c` rather than `swiftc`.
    - It passes `-import-objc-header /Full/Path/To/BridgingHeader.h`.
        - This isn't doc'd under either `swift --help` or `swiftc --help`.
          Heck, `swift --help` doesn't even include the `-c` flag!
    - In debug, the `-enable-testing` flag also gets fed through.
      It also passes in clang flags via `-Xcc` escaping, like `-DDEBUG=1`.
- How does Xcode compile a Swift project, anyway?
    - Xcode's compilation model appears to build each Foo.swift into all of
      Foo~partial.swiftdoc, Foo~partial.swiftmodule, and Foo.o, but with
      a module name set to that of the eventual overall module.
    - It first runs a `swiftc -incremental A.swift B.swift -emit-module
      -emit-objc-header -import-objc-header Foo-Bridging.h -module-name Foo`
      thing. Then it goes through each file independently. Weird!
    - The swiftdeps file dumped with `-emit-reference-dependencies-path` has an
      interesting list of all the identifiers that it cares about, whether they
      support dynamic lookup or not, and an interface hash.
    - After building all the swift files, it then runs a "Merge Module" step.
      Uses `swift -emit-module` rather than `swift -c`.
    - There's a fun `-enable-objc-interop` flag used with all the Swift
      steps. This isn't understood by plain `swift` or plain `swiftc`,
      but works with its
      `swift -frontend -c -primary-file A.swift -enable-objc-interop -o A.o`
      thing.
    - The -frontend flavor expects its own `-sdk` with a full path to the SDK
      folder.
    - The `Foo-Swift.h` header is just the name it uses for the
      `-emit-objc-header-path` filename.
    - That header gets `ditto -rsrc`'d over to the DerivedSources folder.
    - The Foo.swiftmodule gets ditto'd into the built products as
      `Foo.swiftmodule/x86_64.swiftmodule` (for iPhone simulator).
    - The `Foo.swiftdoc` goes into `Foo.swiftmodule/x86_64.swiftdoc`.
- How does Obj-C linking proceed with the Swift stuff?
    - Compilation includes these interesting flags:
      `-fmodules -gmodules -fobjc-abi-version=2 -fobjc-legacy-dispatch`
    - It compiles the file to a `.o` file, so linking is a separate step.
    - It then invokes `clang` to do the final linking. The folder we dropped
      the `Foo.swiftmodule/x86_64.swiftmodule` into is added to `-F`.
      The `-filelist` includes all of the `.o` files, both Swift and Obj-C.
    - Linking adds `-fobjc-link-runtime` but omits `-fobjc-abi-version=2`
      in favor of passing a version flag straight through to the linker.
    - `-Xlinker` is used to pass to the linker:
      `-export_dynamic -no_deduplicate -objc_abi_version 2`
    - And the really interesting one:
      `-Xlinker -add_ast_path -Xlinker Foo.swiftmodule`.
      But it's the one from /Build/Intermediates not /Build/Products, so it's
      what we ditto'd over to `x86_64.swiftmodule` in the built products,
      i.e., the raw `swiftc` module output for our arch.

The "partial then merge" approach is an artefact of Xcode optimizing for
the common case in a large project of wanting separate compilation.
At the CLI, I can skip that.

It looks like, when it's in the same module, it does _not_ build a .framework
hierarchy anywhere. Though it does point `-F` at the folder containing the
multiarch .swiftmodule bundle.

I don't see it feeding in the -Swift.h generated header anywhere.
Probably because I'm not actually using any of the Swift stuff from my
sample Obj-C code. Ah, yeah, you have to manually import the header if
you need it using angle brackets per the using swift with objc docs.

I wonder if I can separately compile the swift file
and then run the obj-c file and link against swift directly, or if
I have to compile both separately, then link them all at the end?

OK, I've got it compiling with me importing the generated Swift header,
but not linking:

```
> ./run initializer-inheritance-objc.m
running: cc -fobjc-arc -fmodules -Xlinker -add_ast_path -Xlinker build/NSSubclass.swiftmodule -F build/ initializer-inheritance-objc.m
Undefined symbols for architecture x86_64:
  "_OBJC_CLASS_$__TtC10NSSubclass10NSSubclass", referenced from:
      objc-class-ref in initializer-inheritance-objc-5f6225.o
ld: symbol(s) not found for architecture x86_64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

This, I think, is where you need that `.o` file generated during Swift
compilation.

`swiftc` itself doesn't understand the `-enable-objc-interop` flag.

Looks like you have to bludgeon `swift -frontend -c` into behaving.
So you want something like `/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk/` on hand.

OK, so if you just run:

```
xcrun -sdk macosx10.12 swift -frontend -c -primary-file initializer-inheritance-and-nsobject.swift -module-name NSSubclass -sdk $SDKPATH -enable-objc-interop -o build/NSSubclass.o
```

it'll emit just the .o file. It's a legit .o file. You have to pass in all the
needed swift files so it can resolve references and stuff. The primary file bit
lets it know which are defined vs imported symbols, I expect.

So you want to `swift` all your files into a module (if you even need it?
maybe not if you aren't linking other Swift stuff against it), then use
the frontend to dump the objc-interop file, then you can feed that into
the compilation of the Obj-C file. And then you're almost there:

```
running: cc -fobjc-arc -fmodules build/NSSubclass.o initializer-inheritance-objc.m
ld: library not found for -lswiftDispatch for architecture x86_64
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```

So we need to link in all the swift library crud.
That's presumably thanks to the fun undefined symbols in our object file like
`__swift_FORCE_LOAD_$_swiftDispatch`.

Running find across $SDKPATH garners:

```
> find $SDKPATH -name '*swiftDispatch*'
/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk//System/Library/PrivateFrameworks/Swift/libswiftDispatch.tbd
```

So, why doesn't Ld barf when Xcode does it? I don't see it doing anything to
vend the swiftlibs. It appears to copy them in after. Maybe it just tells
it "fear not, stuff will show up in time for runtime" via some of those
flags I'm not familiar with, like `-export_dynamic`.

I found the swift libs living under:
/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/

There are shims and such there, too. The macosx folder has a bunch of dylibs
and then an x86_64/ folder with a bunch of compiled apinotes, swiftdoc, and
swiftmodules. So let's try adding that path to -L. And, sure enough, that's
what I see Xcode doing, too, now that I know to look for it!

Now I just need to resolve my "duplicate symbol main" bit.
Probably need to pass in the `-parse-as-library` flag when I build the Swift
file, so it doesn't bundle all the top-level expressions into a C-style
`main()` function.

And `-parse-as-library` tells it not to allow expressions at top level like
the `main()` I had in there originally, because it's not a script. So that's
a very good flag to know!

Ah, it also changes the visibility, though, so that my `internal` class
is no longer exposed!

And, sure enough:

> Swift methods and properties that are marked with the internal modifier and
> declared within a class that inherits from an Objective-C class are
> accessible to the Objective-C runtime. However, they are not accessible at
> compile time and do not appear in the generated header for a framework
> target. (https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html#//apple_ref/doc/uid/TP40014216-CH10-ID172)

What's funny is that, prior to the `-parse-as-library` bit, it DID export
the internal names!

And, with that `public`ized, I can build and link a.out. But I can't run it,
because it expects to dylink against the libswift stuff, and I didn't set
`@rpath`!

```
> ./a.out
dyld: Library not loaded: @rpath/libswiftCore.dylib
  Referenced from: /Users/jeremy/BNR/unconf-swift-dive/language/./a.out
  Reason: image not found
fish: './a.out' terminated by signal SIGTRAP (Trace or breakpoint trap)
```

And, at last, I have the answer I was looking for: You can call it from
Obj-C, but Swift dynamically enforces its own initializer rules:

```
> ./a.out
initializer-inheritance-and-nsobject.swift: 4: 14: fatal error: use of unimplemented initializer 'init()' for class 'NSSubclass.NSSubclass'
fish: './a.out' terminated by signal SIGILL (Illegal instruction)
```

Backtrace looks like:

```
(lldb) bt
* thread #1: tid = 0x257dea6, 0x0000000100001811 a.out`NSSubclass.NSSubclass.init () -> NSSubclass.NSSubclass + 161, queue = 'com.apple.main-thread', stop reason = EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
  * frame #0: 0x0000000100001811 a.out`NSSubclass.NSSubclass.init () -> NSSubclass.NSSubclass + 161
    frame #1: 0x0000000100001871 a.out`@objc NSSubclass.NSSubclass.init () -> NSSubclass.NSSubclass + 17
    frame #2: 0x00000001000027f7 a.out`main + 39
    frame #3: 0x00007fff803255ad libdyld.dylib`start + 1
```

So it looks like it intentionally overrid it just to trip a `fatalError`.

The disassembly is, uh, "fun":

```
a.out`NSSubclass.NSSubclass.init () -> NSSubclass.NSSubclass:
    0x100001770 <+0>:   pushq  %rbp
    0x100001771 <+1>:   movq   %rsp, %rbp
    0x100001774 <+4>:   subq   $0x10, %rsp
    0x100001778 <+8>:   movq   %rdi, -0x8(%rbp)
    0x10000177c <+12>:  jmp    0x10000177e               ; <+14>
    0x10000177e <+14>:  jmp    0x100001780               ; <+16>
    0x100001780 <+16>:  jmp    0x100001782               ; <+18>
    0x100001782 <+18>:  jmp    0x100001784               ; <+20>
    0x100001784 <+20>:  jmp    0x100001786               ; <+22>
    0x100001786 <+22>:  jmp    0x100001788               ; <+24>
    0x100001788 <+24>:  jmp    0x10000178a               ; <+26>
    0x10000178a <+26>:  jmp    0x10000178c               ; <+28>
    0x10000178c <+28>:  jmp    0x10000178e               ; <+30>
    0x10000178e <+30>:  jmp    0x100001790               ; <+32>
    0x100001790 <+32>:  leaq   0x1979(%rip), %rax
    0x100001797 <+39>:  addq   $0x10, %rax
    0x10000179b <+43>:  movl   $0x50, %ecx
    0x1000017a0 <+48>:  movl   %ecx, %esi
    0x1000017a2 <+50>:  movl   $0x7, %ecx
    0x1000017a7 <+55>:  movl   %ecx, %edx
    0x1000017a9 <+57>:  movq   %rax, %rdi
    0x1000017ac <+60>:  callq  0x100001e80               ; rt_swift_allocObject
    0x1000017b1 <+65>:  leaq   0x1298(%rip), %rsi        ; "NSSubclass.NSSubclass"
    0x1000017b8 <+72>:  movl   $0x15, %ecx
    0x1000017bd <+77>:  movl   %ecx, %edx
    0x1000017bf <+79>:  movl   $0x2, %ecx
    0x1000017c4 <+84>:  leaq   0x6c5(%rip), %r8          ; partial apply forwarder for Swift.(_unimplementedInitializer (className : Swift.StaticString, initName : Swift.StaticString, file : Swift.StaticString, line : Swift.UInt, column : Swift.UInt) -> Swift.Never).(closure #1)
    0x1000017cb <+91>:  leaq   0x129e(%rip), %r9         ; "initializer-inheritance-and-nsobject.swift"
    0x1000017d2 <+98>:  leaq   0x128d(%rip), %r10        ; "init()"
    0x1000017d9 <+105>: movq   %r10, 0x10(%rax)
    0x1000017dd <+109>: movq   $0x6, 0x18(%rax)
    0x1000017e5 <+117>: movb   $0x2, 0x20(%rax)
    0x1000017e9 <+121>: movq   %r9, 0x28(%rax)
    0x1000017ed <+125>: movq   $0x2a, 0x30(%rax)
    0x1000017f5 <+133>: movb   $0x2, 0x38(%rax)
    0x1000017f9 <+137>: movq   $0x4, 0x40(%rax)
    0x100001801 <+145>: movq   $0xe, 0x48(%rax)
    0x100001809 <+153>: movq   %rax, %r9
    0x10000180c <+156>: callq  0x100001a20               ; function signature specialization <preserving fragile attribute, Arg[1] = [Closure Propagated : reabstraction thunk helper from @callee_owned (@unowned Swift.UnsafeBufferPointer<Swift.UInt8>) -> () to @callee_owned (@unowned Swift.UnsafeBufferPointer<Swift.UInt8>) -> (@out ()), Argument Types : [@callee_owned (@unowned Swift.UnsafeBufferPointer<Swift.UInt8>) -> ()]> of generic specialization <preserving fragile attribute, ()> of Swift.StaticString.withUTF8Buffer <A> ((Swift.UnsafeBufferPointer<Swift.UInt8>) -> A) -> A
->  0x100001811 <+161>: ud2
    0x100001813 <+163>: nopw   %cs:(%rax,%rax)
```

That specialization / fragile reabstraction thunk closure attribute / generic
specialization stuff is interesting. Also interesting that it allocates the
object, only to die via the `_unimplementedInitializer`. I didn't pass any
particular optimization level in, so maybe this'd get more simplified at higher
optimization levels. But you can see it loading up the arguments for that
partial apply forwarder. That jump slide at the top is weird, too. Why not just
nops? Padding it out so instructions fall at a certain alignment?


### Type Erasure
Yeah. Let's do this.

Resources:

- https://realm.io/news/type-erased-wrappers-in-swift/
- https://github.com/bignerdranch/type-erasure-playgrounds
- http://www.russbishop.net/type-erasure
- http://www.russbishop.net/inception

#### Type-Erased Wrappers in Swift
- https://realm.io/news/type-erased-wrappers-in-swift/

"What if we want to treat a protocol as a generic?"

Motivating example:

```
struct Item {}

struct ItemHolder {
    var items: Collection<Item>
}
```

This bails with:

```
error: repl.swift:2:25: error: cannot specialize non-generic type 'Collection'
struct ItemHolder { var items: Collection<Item> }
                        ^         ~~~~~~
```

Trying with just bare `: Collection` gives a similar error:

```
error: repl.swift:2:25: error: protocol 'Collection' can only be used as a generic constraint because it has Self or associated type requirements
struct ItemHolder { var items: Collection }
                        ^
```

Because, well, protocol types aren't generic. If you really mean
"anything satisfying this protocol", then you're parameterizing your type
over implementors of that protocol, so _you're_ writing a generic type!

**But why does that only kick in when it comes to `Self` and associated
types?** Why not every protocol? I suspect implementation constraints
interfere. But let's see.

Those with `Self` or associated type requirements can put constraints on the
types that can be substituted as either `Self` or an associated type `Element`,
such as that `Element` must be `Hashable` or `Equatable` or similar.
An associated type also means that code using the type has to treat those
types as generic.

Anyway, back to the article:

- We want to erase the specific concrete type implementing the protocol
  with associated types.
- We replace it with a type that's generic over the associated type,
  and then we can force that generic type to line up with the associated type.
- We replace it by substituting a concrete type implementing the protocol
  and generic in the element type. Now our `ItemHolder` is no longer
  itself generic, as it knows it's talking to a very specific type,
  our `AnySequence<Item>` type.
- But we still have the issue of needing to deal with a variety of
  implementors of that protocol. So we still have genericity around the
  actual `Sequence` implementor to deal with. We handle that by employing
  a subclass that adds a generic parameter on top of the one already in
  `AnySequence<Element>`. This generic parameter is a `T: Sequence`.
  And it demands that its element type line up with its superclass's Element
  generic type.
- To implement `Sequence` without actually having a sequence in our
  `AnySequence` meant we just had to fatal error out for each method.
  Oops. The subclass can forward to the underlying type that it's generic over,
  so it actually implements stuff. This is kinda messy.
- So now we go ahead and rename `AnySequence<Element>` to an internal
  `_AnySequenceBoxBase<Element>`, the subclass to
  `_AnySequenceBox<T: Sequence>: _AnySequenceBoxBase<Sequence.Generator.Element>`,
  and create a new façade `AnySequence<Element>` that takes a `Sequence`
  argument, feeds it into a `_AnySequenceBox`, exploits polymorphism by
  stashing it in a `_AnySequenceBoxBase`, and forwards through to that
  in its implementation of `Sequence`.
- Notice how the actual `Sequence` genericity is contained inside a private
  property of `AnySequence<Element>`, and the `S: Sequence` doesn't show
  up in its type anywhere? That's the "erasure" bit.

So:

- Generic façade
- Exploding generic type used as our interface to the actual generic sequence;
  this is the erasure magic!
- Functional doubly-generic subclass of the exploding generic type

And we basically end up
**substituting subtype polymorphism for parametric polymorphism.**


## Unanswered Questions
- Language:
    - One more thing on type erasure:
        - ???: The requirement to use it only for PATs and not for all
          protocols isn't clear to me semantically, though. (I think it could
          more readily be made clear to me by implementation operational
          requirements, but I'm not sure there, either.)
        - Maybe some insight lies in the other resources I haven't read yet:
            - https://github.com/bignerdranch/type-erasure-playgrounds
            - http://www.russbishop.net/type-erasure
            - http://www.russbishop.net/inception
    - What are the semantics around value capture in a closure?
      What happens when you have racing around a closure, or change a captured
      value after creating the closure?
    - Type aliases can have their access controlled separately from the
      thing they alias. How does extending a type alias impact the access
      level of things in that extension?
    - Constrained extensions on protocols
    - Protocol-Oriented Programming review

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
    - What the heck is an archetype? Shows up all over in the
      compiler source, mentioned in then typechecker doc, defined NOWHERE!
    - What's with the "jump slide" in some function prologs?

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


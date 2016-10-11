- exhaustiveness: Swift files playing around with integer sizes.
  UInt8 and Int8 are small enough we can enumerate them easily with a script.
  Teaches that:
    - enum raw value assignment is literally the equivalent of
      `let caseName = NextValueAsIntLiteral`, and if the literal overflows, you
      get a standard warning.
    - The Swift compiler does NOT treat its numeric types as enumerations,
      even though they are all enumerable. (Yes, even `Double`: It's got
      a fixed bitwidth, so just run through all the (many!) permutations, and
      you're done.) So, even if you have `case 0:` through `case 255:` while
      switching over a `UInt8`, it just assumes you're not exhaustive unless
      you pitch in a `default:`. Boo!
- init-inheritance: This started out as "what happens when Obj-C's initializer
  inheritance rules meet Swift's?" and turned into "hey how do I compile and
  link Swift and Obj-C together myself, without a .xcodeproj entering the
  scene?" Things I learned:
    - The Swift frontend has an `-enable-objc-interop` flag that causes it to
      drop a `.o` file for the `-primary-file` of Swift you feed it. You need
      this to link the Obj-C code against.
    - To successfully link the Obj-C binary, you need to aim it at the
      libswiftFoo.dylibs hiding in Xcode's
      /Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macsox
      folder. To successfully run the resulting binary, you want to aim the
      rpath at that directory, too.
    - The Swift generated header only includes public stuff, because you're
      building it as a library. But that happens to include the inherited
      initializers, though they're marked as `SWIFT_UNAVAILABLE`.
      **These unimplemented but still exported initializers are landmines:**
      These should be marked as unavailable to Obj-C, too,
      because calling them trips an "unimplemented initializer" **fatal error**
      that the Swift compiler so helpfully generated. **Swift protects its
      initializer expectations harshly!**

# Init Inheritance
This is where I poke at how initializer inheritance works across languages.

`NSSubclass.h` is one of the results of compiling
`initializer-inheritance-and-nsobject.swift` as detailed in the first line of
that file.

`initializer-inheritance-objc.m` uses that and another compilation product to
build a little executable that will crash if it doesn't play by Swift's "we
don't inherit initializers unless they're required" rules. Fun fun!

`SameModuleSharing` is an Xcode project I used to get it to dump compiler logs
for me to grovel through. Hey, I know _it_ knows how to compile this mess, so
if I look at what it does, I can learn how to do it myself, yeah?

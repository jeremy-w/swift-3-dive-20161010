// swiftc {} -module-name SuchModule -o build/archetype
/*
 NOTE: This is taken straight from
 https://github.com/apple/swift/blob/swift-3.0-RELEASE/test/Constraints/members.swift#L143-L244

 As such, this chunk of code is licensed under the Apache License v2.0:
 https://github.com/apple/swift/blob/swift-3.0-RELEASE/LICENSE.txt

 On Thursday, 13 Oct 2016,
 I pulled in the extract and commented out the intentional errors
 in order to compile it and then demangle the symbols, to see
 if I could find any of the characteristic archetype-related demanglings,
 as part of understanding what an "archetype" is.
 */
////
// Members of archetypes
////

func id<T>(_ t: T) -> T { return t }

protocol P {
  init()
  func bar(_ x: Int)
  mutating func mut(_ x: Int)
  static func tum()
}

extension P {
  func returnSelfInstance() -> Self {
    return self
  }

  func returnSelfOptionalInstance(_ b: Bool) -> Self? {
    return b ? self : nil
  }

  func returnSelfIUOInstance(_ b: Bool) -> Self! {
    return b ? self : nil
  }

  static func returnSelfStatic() -> Self {
    return Self()
  }

  static func returnSelfOptionalStatic(_ b: Bool) -> Self? {
    return b ? Self() : nil
  }

  static func returnSelfIUOStatic(_ b: Bool) -> Self! {
    return b ? Self() : nil
  }
}

protocol ClassP : class {
  func bas(_ x: Int)
}

func generic<T: P>(_ t: T) {
  var t = t
  // Instance member of archetype
  let name0: (Int) -> () = id(t.bar)
  let name1: () = id(t.bar(0))

  // Static member of archetype metatype
  let name2: () -> () = id(T.tum)

  // Instance member of archetype metatype
  let name3: (T) -> (Int) -> () = id(T.bar)
  let name4: (Int) -> () = id(T.bar(t))

  //_ = t.mut // expected-error{{partial application of 'mutating' method is not allowed}}
  //_ = t.tum // expected-error{{static member 'tum' cannot be used on instance of type 'T'}}

  // Instance member of extension returning Self)
  let name5: (T) -> () -> T = id(T.returnSelfInstance)
  let name6: () -> T = id(T.returnSelfInstance(t))
  let name7: T = id(T.returnSelfInstance(t)())

  let name8: () -> T = id(t.returnSelfInstance)
  let name9: T = id(t.returnSelfInstance())

  let name10: (T) -> (Bool) -> T? = id(T.returnSelfOptionalInstance)
  let name11: (Bool) -> T? = id(T.returnSelfOptionalInstance(t))
  let name12: T? = id(T.returnSelfOptionalInstance(t)(false))

  let name13: (Bool) -> T? = id(t.returnSelfOptionalInstance)
  let name14: T? = id(t.returnSelfOptionalInstance(true))

  let name15: (T) -> (Bool) -> T! = id(T.returnSelfIUOInstance)
  let name16: (Bool) -> T! = id(T.returnSelfIUOInstance(t))
  let name17: T! = id(T.returnSelfIUOInstance(t)(true))

  let name18: (Bool) -> T! = id(t.returnSelfIUOInstance)
  let name19: T! = id(t.returnSelfIUOInstance(true))

  // Static member of extension returning Self)
  let name20: () -> T = id(T.returnSelfStatic)
  let name21: T = id(T.returnSelfStatic())

  let name22: (Bool) -> T? = id(T.returnSelfOptionalStatic)
  let name23: T? = id(T.returnSelfOptionalStatic(false))

  let name24: (Bool) -> T! = id(T.returnSelfIUOStatic)
  let name25: T! = id(T.returnSelfIUOStatic(true))
}

func genericClassP<T: ClassP>(_ t: T) {
  // Instance member of archetype)
  let name26: (Int) -> () = id(t.bas)
  let name27: () = id(t.bas(0))

  // Instance member of archetype metatype)
  let name28: (T) -> (Int) -> () = id(T.bas)
  let name29: (Int) -> () = id(T.bas(t))
  let name30: () = id(T.bas(t)(1))
}

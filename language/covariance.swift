// swift {}
/*
 Are arrays covariant? Yes.
 */

class Parent {
    func name() -> String { return "parent" }
}
class Child: Parent {
    override func name() -> String { return "child" }
}

let parents = [Parent(), Parent(), Parent()]
let children = [Child(), Child(), Child()]
let childrenAsParents: [Parent] = children
print("parents \(parents) - children \(children) - childrenAsParents \(childrenAsParents)")

// This correctly does dynamic dispatch, as you'd expect for a class type.
print("parents \(parents.map { $0.name() }) - children \(children.map { $0.name() }) - childrenAsParents \(childrenAsParents.map { $0.name() })")


/*
 Are user-defined generics covariant? Yes.
 */
struct Wrapper<Contents> {
    let value: Contents
}
let wrappedParent = Wrapper(value: Parent())
let wrappedChild = Wrapper(value: Child())
let wrappedChildAsParent: Wrapper<Parent> = Wrapper(value: Child())
print("wrappedChildAsParent \(wrappedChildAsParent)")
//let NOPE_wrappedParentAsChild: Wrapper<Child> = Wrapper(value: Parent())
// error: cannot convert value of type 'Wrapper<Parent>' to specified type
//        'Wrapper<Child>'


/*
 Are functions covariant in their return type? Yes.
 You can return a more specific return type than declared.
 */
let returnsParent: (() -> Parent) = { _ in return Child() }

/*
 Are functions contravariant in their argument type? Yes.
 You can take a more general argument type than declared.
 */
//let cannotAssignClosureTakingChildToOneTakingParent: (Parent) -> Void = { (c: Child) -> Void in return }
let canAssignClosureTakingParentToOneTakingChild: (Child) -> Void = { (p: Parent) -> Void in return }


/*
 What happens when function argument contravariance meets generic parameters?
 **Stuff breaks.**

 What is up with that reported type of `(_) -> Void`?
 */
struct FnWrapper<Contents> {
    let value: (Contents) -> Void
}
let genericClosureTakingParent: FnWrapper<Parent>
/*
 running: swift covariance.swift
 covariance.swift:55:55: error: cannot convert value of type '(Child) -> Void' to expected argument type '(_) -> Void'
 genericClosureTakingParent = FnWrapper<Parent>(value: { (c: Child) -> Void in return })
                                                       ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 */
//genericClosureTakingParent = FnWrapper { (c: Child) -> Void in return }


/*
 What about at the type level? Is class B a subtype of class A?
 Yes.
 */
class A {}; class B: A {};
let typeOfA: A.Type = B.self


/*
 Is a protocol type InheritsP a subtype of protocol P?
 **No!**

    covariance.swift:80:27: error: cannot convert value of type
      'InheritsP.Protocol' to specified type 'P.Protocol'
    let typeOfP: P.Protocol = InheritsP.self
                              ^~~~~~~~~
 */
protocol P {}; protocol InheritsP: P {};
//let typeOfP: P.Protocol = InheritsP.self

/*
 What about doing the classic inheritance trick of broadening the
 acceptable values of an inherited function, but with protocol inheritance?

 No dice! It has to implement both.

 We can use a default extension to implement the Narrow requirement in terms of
 Broad's, though, like a manual version of the classic inheritance scenario.
 */
protocol Narrow { func shared(value: Child) }
protocol Broad: Narrow { func shared(value: Parent) }
struct DoesItGetOneOrTwoProtocolRequirements: Broad {
    func shared(value: Parent) {}
}
extension Broad {
    func shared(value: Child) {
        shared(value: value as Parent)
    }
}


/*
 What if we stuff a generic in our generic?
 No problem!
 */
let collections: [AnyCollection<Parent>] = [
    AnyCollection([Parent(), Parent()]),
    AnyCollection([Child(), Parent()].dropFirst()),
]
print("collections: \(collections)")

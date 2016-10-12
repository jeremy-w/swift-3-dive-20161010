// swift -target x86_64-apple-macosx10.10 {}
// Needed to set a target to stop griping about unavailability of the
// async(qos:) flavor prior to 10.10
/*
 What happens if we have a reader-writer race with a captured
 closure value?
 */
import Dispatch

struct BigValue {
    let a1: Int
    let a2: Int
    let a3: Int
    let a4: Int
    let a5: Int
    let a6: Int
    var a7: Int
    let a8: Int
    let a9: Int
    let a10: Int
    let a11: Int
    let a12: Int
    let a13: Int
    let a14: Int
}
var captured = BigValue(
    a1: 1,
    a2: 2,
    a3: 3,
    a4: 4,
    a5: 5,
    a6: 6,
    a7: 0,
    a8: 8,
    a9: 9,
    a10: 10,
    a11: 11,
    a12: 12,
    a13: 13,
    a14: 14
)

func spawnMutator(_ mutator: @escaping () -> Void = { captured.a7 += 1 }) {
    DispatchQueue.global().async {
        mutator()
    }
}

func incr(by count: Int, then final: () -> Void) {
    let group = DispatchGroup()
    for _ in 0 ..< count {
        group.enter()
        DispatchQueue.global().async {
            spawnMutator()
            //print("\(captured)")
            group.leave()
        }
    }
    group.wait()
    final()
}

let delta = 10_000
incr(by: delta, then: {
    // This is regularly around 9_800 to 9_900 on my machine.
    // Capturing value types by reference lets us have the same fun
    // we always have with concurrency. Yay! ;_;
    print("expected \(delta), got: \(captured.a7)")
    exit(0)
})
dispatchMain()

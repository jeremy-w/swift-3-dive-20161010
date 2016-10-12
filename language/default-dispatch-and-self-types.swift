// swift {}
/*
 Playing around with protocols with self-type requirements and extension
 methods. Yup, that is totally static dispatch.

 - date: 2016-10-12
 */
protocol Kick {
    func kick(_ other: Self) -> String
    //func smudge(_ other: Kick) -> String
    var value: String { get }
}

extension Kick {
    var value: String { return "default implementation" }
    func echo(_ string: String) -> String {
        return string
    }
}

struct Target: Kick {
    func kick(_ other: Target) -> String {
        return other.value
    }

    /*override, effectively*/
    func echo(_ string: String) -> String { return "target" }

    // Even though this is a protocol requirement, the extension
    // satisfies it for us. We can override it if we want to, though.
    //var value: String { return "target's implementation" }
}

func kick<T: Kick>(it: T) -> String {
    return it.kick(it)
}

let t = Target()
let t2 = Target()
print("t.kick(t2): \(t.kick(t2))")
print("kick(it: t): \(kick(it: t))")
print("t.echo(\"default impl\"): \(t.echo("default impl"))")

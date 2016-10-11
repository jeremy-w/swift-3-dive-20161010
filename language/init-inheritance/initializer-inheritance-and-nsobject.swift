// xcrun -sdk macosx10.12 swift -frontend -c -primary-file {} -sdk /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk/ -module-name NSSubclass -emit-module-path build/NSSubclass.swiftmodule -emit-objc-header-path build/NSSubclass.h -enable-testing -enable-objc-interop -parse-as-library -o build/NSSubclass.o
import Foundation

public class NSSubclass: NSObject {
    public let newThing: String

    public init(newThing: String) {
        self.newThing = newThing
        super.init()
    }
}

func main() {
    /*
 The inherited initializer is NOT exposed to Swift:
    let obj = NSSubclass()
initializer-inheritance-and-nsobject.swift:13:25: error: missing argument for parameter 'newThing' in call
    let obj = NSSubclass()
                        ^
initializer-inheritance-and-nsobject.swift:6:5: note: 'init(newThing:)' declared here
    init(newThing: String) {
    ^
*/
    let obj = NSSubclass(newThing: "mumble")
    print("obj: \(String(reflecting: obj))")
}

/*
 -parse-as-library disables "scripting" support, so no top-level code to run,
 only definitions:

initializer-inheritance-and-nsobject.swift:28:1: error: expressions are not allowed at the top level
main()
^

*/
// main()

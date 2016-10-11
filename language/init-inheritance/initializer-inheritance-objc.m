// cc -fobjc-arc -fmodules -L /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx/ -Xlinker -rpath -Xlinker /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx/ build/NSSubclass.o {}
@import Foundation;
#import "build/NSSubclass.h"

int
main(void) {
    @autoreleasepool {
        NSSubclass *obj = [NSSubclass new];
        NSLog(@"object: %@", obj);
        NSLog(@"value: %@", obj.newThing);
    }
}

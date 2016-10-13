// swiftc {} -o build/constrained_extensions
protocol ExtendMe {
    associatedtype Item
    var items: AnyCollection<Item> { get }
}

extension ExtendMe
    where Item == Int {
    var sum: Int {
        return items.reduce(0, +)
    }
}

extension ExtendMe
    where Item: BitwiseOperations {
    var sum: Item {
        return items.reduce(Item.allZeros, |)
    }
}

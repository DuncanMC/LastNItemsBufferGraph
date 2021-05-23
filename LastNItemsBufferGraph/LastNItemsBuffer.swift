//
//  LastNItemsBuffer.swift
//  LastNItemsBufferGraph
//
//  Created by Duncan Champney on 5/23/21.
//

import Foundation

public struct LastNItemsBuffer<T> {
    fileprivate var array: [T?]
    fileprivate var index = 0

//    var foo: FooType ÷
    var count: Int {
        return array.count
    }
    
    public init(count: Int) {
        array = [T?](repeating: nil, count: count)
    }

    public mutating func clear() {
        forceToValue(nil)
    }

    public mutating func forceToValue(_ value: T?) {
        let count = array.count
        array = [T?](repeating: value, count: count)
    }

    public mutating func write(_ element: T) {
        array[index % array.count] = element
        index += 1
    }
    public func lastNItems() -> [T] {
        var result = [T?]()
        for loop in 0..<array.count {
            result.append(array[(loop+index) % array.count])
        }
        return result.compactMap { $0 }
    }
}

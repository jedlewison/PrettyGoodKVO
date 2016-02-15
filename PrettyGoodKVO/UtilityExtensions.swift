//
//  UtilityExtensions.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/4/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

extension Set: Updatable { }
protocol Updatable {}
extension Updatable {
    func with(change: (inout Self) -> ()) -> Self {
        var update = self
        change(&update)
        return update
    }
}

extension Set {

    func inserting(element: Element) -> Set {
        var update = self
        update.insert(element)
        return update
    }

}

extension Dictionary {

    mutating func transformValueForKey(key: Key, @noescape transform: (Value? -> Value?)) {
        self[key] = transform(self[key])
    }
    
}

func performClosure(@autoclosure(escaping) closure: () -> (), onQueue queue: NSOperationQueue?) {
    if let opQueue = queue where .currentQueue() != queue {
        opQueue.addOperationWithBlock {
            closure()
        }
    } else {
        closure()
    }
}

public protocol OptionalType: NilLiteralConvertible {
    typealias WrappedType
    init(_ some: WrappedType)
    init()
}

extension OptionalType {
    init(valueOrNil: WrappedType?) {
        if let valueOrNil = valueOrNil {
            self.init(valueOrNil)
        } else {
            self.init()
        }
    }
}

extension Optional: OptionalType {
    public typealias WrappedType = Wrapped
}

extension NSObjectProtocol {

    var asNSObject: NSObject {
        return self as! NSObject
    }

}


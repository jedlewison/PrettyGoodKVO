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

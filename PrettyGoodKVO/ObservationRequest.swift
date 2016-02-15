//
//  ObservationRequest.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/4/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

final class ObservationRequest {
    let identifier = NSProcessInfo.processInfo().globallyUniqueString
    let client: WeakClientBox
    let closure: PGKVOObservationClosure
    let options: NSKeyValueObservingOptions
    let keyPath: String
    init(client: AnyObject, keyPath: String, options: NSKeyValueObservingOptions, closure: PGKVOObservationClosure) {
        self.client = WeakClientBox(client: client)
        self.keyPath = keyPath
        self.options = options
        self.closure = closure
    }
}

extension ObservationRequest: Hashable {
    var hashValue: Int { return identifier.hashValue }
}

func ==(lhs: ObservationRequest, rhs: ObservationRequest) -> Bool {
    return lhs.identifier == rhs.identifier
}

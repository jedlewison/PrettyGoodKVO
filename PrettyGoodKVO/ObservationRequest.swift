//
//  ObservationRequest.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/4/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

internal struct ObservationRequest: Hashable {
    let identifier = ProcessInfo.processInfo().globallyUniqueString
    let clientBox: WeakClientBox
    let keyPath: String
    let options: NSKeyValueObservingOptions
    let closure: PGKVOObservationClosure
    var hashValue: Int { return identifier.hashValue }
}

func ==(lhs: ObservationRequest, rhs: ObservationRequest) -> Bool {
    return lhs.identifier == rhs.identifier
}

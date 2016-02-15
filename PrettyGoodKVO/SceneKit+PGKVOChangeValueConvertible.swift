//
//  PGKVOValueConvertible.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/7/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import SceneKit

extension SCNVector3: PGKVOChangeNSValueConvertible {
    public init?(changeValue: NSValue) {
        self = changeValue.SCNVector3Value
    }
}

extension SCNVector4: PGKVOChangeNSValueConvertible {
    public init?(changeValue: NSValue) {
        self = changeValue.SCNVector4Value
    }
}

extension SCNMatrix4: PGKVOChangeNSValueConvertible {
    public init?(changeValue: NSValue) {
        self = changeValue.SCNMatrix4Value
    }
}
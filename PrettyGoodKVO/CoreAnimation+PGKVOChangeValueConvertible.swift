//
//  PGKVOValueConvertible.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/7/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import QuartzCore

extension CATransform3D: PGKVOChangeNSValueConvertible {
    public init?(changeValue: NSValue) {
        self = changeValue.CATransform3DValue
    }
}
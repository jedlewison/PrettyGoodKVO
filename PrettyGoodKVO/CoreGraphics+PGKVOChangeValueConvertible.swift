//
//  PGKVOValueConvertible.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/7/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import CoreGraphics

extension CGRect: PGKVOChangeNSValueConvertible {
    public init?(changeValue: NSValue) {
        self = changeValue.CGRectValue()
    }
}

extension CGPoint: PGKVOChangeNSValueConvertible {
    public init?(changeValue: NSValue) {
        self = changeValue.CGPointValue()
    }
}

extension CGSize: PGKVOChangeNSValueConvertible {
    public init?(changeValue: NSValue) {
        self = changeValue.CGSizeValue()
    }
}

extension CGVector: PGKVOChangeNSValueConvertible {
    public init?(changeValue: NSValue) {
        self = changeValue.CGVectorValue()
    }
}

extension CGAffineTransform: PGKVOChangeNSValueConvertible {
    public init?(changeValue: NSValue) {
        self = changeValue.CGAffineTransformValue()
    }
}
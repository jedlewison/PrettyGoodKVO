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
        self = changeValue.cgRectValue()
    }
}

extension CGPoint: PGKVOChangeNSValueConvertible {
    public init?(changeValue: NSValue) {
        self = changeValue.cgPointValue()
    }
}

extension CGSize: PGKVOChangeNSValueConvertible {
    public init?(changeValue: NSValue) {
        self = changeValue.cgSizeValue()
    }
}

extension CGVector: PGKVOChangeNSValueConvertible {
    public init?(changeValue: NSValue) {
        self = changeValue.cgVectorValue()
    }
}

extension CGAffineTransform: PGKVOChangeNSValueConvertible {
    public init?(changeValue: NSValue) {
        self = changeValue.cgAffineTransform()
    }
}

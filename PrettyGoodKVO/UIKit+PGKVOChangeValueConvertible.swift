//
//  PGKVOValueConvertible.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/7/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import UIKit

extension UIEdgeInsets: PGKVOChangeNSValueConvertible {
    public init?(changeValue: NSValue) {
        self = changeValue.UIEdgeInsetsValue()
    }
}

extension UIOffset: PGKVOChangeNSValueConvertible {
    public init?(changeValue: NSValue) {
        self = changeValue.UIOffsetValue()
    }
}
//
//  PGKVOValueConvertible.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/7/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

public protocol PGKVOChangeValueConvertible {
    init?(changeValue: AnyObject)
}

public protocol PGKVOChangeNSValueConvertible: PGKVOChangeValueConvertible {
    init?(changeValue: NSValue)
}

public extension PGKVOChangeNSValueConvertible {
    init?(changeValue: AnyObject) {
        guard let changeValue = changeValue as? NSValue else { return nil }
        self.init(changeValue: changeValue)
    }
}

public extension PGKVOChangeValueConvertible {

    public init?(changeValue: AnyObject) {
        guard let unwrapped = changeValue as? Self else { return nil }
        self = unwrapped
    }
    
}

public extension PGKVOChangeValueConvertible where Self: RawRepresentable {
    public init?(changeValue: AnyObject) {
        guard let changeValue = changeValue as? Self.RawValue else { return nil }
        self.init(rawValue: changeValue)
    }
}

extension Optional: PGKVOChangeValueConvertible {
    public init?(changeValue: AnyObject) {
        if let convertibleType = Wrapped.self as? PGKVOChangeValueConvertible.Type,
            unwrapped = convertibleType.init(changeValue: changeValue) as? Wrapped {
            self = unwrapped
        } else {
            self = changeValue as? Wrapped
        }
    }
}

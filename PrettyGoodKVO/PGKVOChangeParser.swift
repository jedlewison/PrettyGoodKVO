//
//  PGKVOChangeValues.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/8/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

enum ChangeKey {

    case Old
    case New

    init?(rawValue: String) {
        switch rawValue {
        case NSKeyValueChangeOldKey:
            self = .Old
        case NSKeyValueChangeNewKey:
            self = .New
        default:
            return nil
        }
    }

    var rawValue: String {
        return self == .Old ? NSKeyValueChangeOldKey : NSKeyValueChangeNewKey
    }
}

struct PGKVOChangeParser {
    let raw: [String : AnyObject]
    let keyPath: String
    init(raw: [String : AnyObject]?, keyPath: String) throws {
        guard let raw = raw else { throw PGKVOError.NilChangeDictionary }
        self.raw = raw
        self.keyPath = keyPath
    }

    func hasChange() -> Bool {
        return objcValueForChange(.Old) != objcValueForChange(.New)
    }

    private func objcValueForChange(changeKey: ChangeKey) -> NSObject? {
        return rawValueForChange(changeKey) as? NSObject
    }

    private func rawValueForChange(changeKey: ChangeKey) -> AnyObject? {
        return raw[changeKey.rawValue]
    }

    private func parseValueForChange<T>(changeKey: ChangeKey) throws -> T {
        guard let value = rawValueForChange(changeKey) else {
            throw PGKVOError.CouldNotConvert(from: nil, to: T.self)
        }

        if let value = value as? T {
            return value
        } else if let convertibleType = T.self as? PGKVOChangeValueConvertible.Type,
            value = convertibleType.init(changeValue: value) as? T {
                return value
        }

        throw PGKVOError.CouldNotConvert(from: value, to: T.self)

    }

    func valueForChange<T: OptionalType>(changeKey: ChangeKey) throws -> T {
        guard let value = rawValueForChange(changeKey)
            where !(value is NSNull) else { return T() }
        return T(try valueForChange(changeKey) as T.WrappedType)
    }

    func valueForChange<T>(changeKey: ChangeKey) throws -> T {
        return try parseValueForChange(changeKey)
    }
    
}


//
//  PGKVOChangeKind.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 5/22/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

public enum PGKVOChangeKind<Value> {
    case initial(Value)
    case change(old: Value, new: Value)

    public var value: Value {
        switch self {
        case .initial(let value):
            return value
        case .change(let values):
            return values.new
        }
    }

    public var changeValues: (old: Value, new: Value)? {
        switch self {
        case .initial:
            return nil
        case .change(let values):
            return values
        }
    }

    public var isInitial: Bool {
        switch self {
        case .initial:
            return true
        case .change:
            return false
        }
    }

    internal init?(changes: [String : AnyObject]?) {
        guard let changes = changes
            where changes.hasKVOChange() else { return nil }
        do {
            let old: Value = try changes.valueForChange(.old)
            let new: Value = try changes.valueForChange(.new)
            self = .change(old: old, new: new)
        } catch {
            debugPrint(error)
            return nil
        }
    }
}

// MARK: - Private utilities for parsing the changes dictionary

private struct KeyValueChangeKind {
    static let old = KeyValueChangeKind(key: NSKeyValueChangeOldKey)
    static let new = KeyValueChangeKind(key: NSKeyValueChangeNewKey)
    let key: String
}

private protocol PGKVOStringProtocol { }
extension String: PGKVOStringProtocol { }

private extension Dictionary where Key: PGKVOStringProtocol, Value: AnyObject {

    subscript (changeKey: KeyValueChangeKind) -> Value? {
        guard let key = changeKey.key as? Key else { return nil }
        return self[key]
    }

    func objcValueForChange(changeKey: KeyValueChangeKind) -> NSObject? {
        return self[changeKey] as? NSObject
    }

    func hasKVOChange() -> Bool {
        return objcValueForChange(.old) != objcValueForChange(.new)
    }

    func valueForChange<T>(changeKey: KeyValueChangeKind) throws -> T {
        // Make sure we actually have a value
        guard let rawValue = self[changeKey] else { throw PGKVOError.NilChangeDictionary }

        // Unwrap the value to the expected type, or fail
        switch T.self {
        case let convertibleType as PGKVOChangeValueConvertible.Type:
            // Try to bridge conforming value types from an AnyObject
            if let convertedValue = convertibleType.init(changeValue: rawValue) as? T {
                return convertedValue
            }
        case _:
            // Try a dynamic cast (may involve magical bridging)
            if let unwrappedValue = rawValue as? T {
                return unwrappedValue
            }
        }

        throw PGKVOError.CouldNotConvert(from: rawValue, to: T.self)
    }
    
}

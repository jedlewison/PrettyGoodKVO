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

    internal init?(changes: [NSKeyValueChangeKey : AnyObject]?) {
        guard let changes = changes
            where PGKVOChangeKind.valuesChanged(inChanges: changes) else { return nil }
        do {
            let old: Value = try PGKVOChangeKind.value(forChangeKey: .oldKey, inChanges: changes)
            let new: Value = try PGKVOChangeKind.value(forChangeKey: .newKey, inChanges: changes)
            self = .change(old: old, new: new)
        } catch {
            debugPrint(error)
            return nil
        }
    }

}

private extension PGKVOChangeKind {

    private static func valuesChanged(inChanges changes: [NSKeyValueChangeKey : AnyObject]) -> Bool {
        return objcValue(forChangeKey: .oldKey, inChanges: changes) != objcValue(forChangeKey: .newKey, inChanges: changes)
    }

    private static func objcValue(forChangeKey changeKey: NSKeyValueChangeKey, inChanges changes: [NSKeyValueChangeKey : AnyObject]) -> NSObject? {
        return changes[changeKey] as? NSObject
    }

    private static func value<T>(forChangeKey changeKey: NSKeyValueChangeKey, inChanges changes: [NSKeyValueChangeKey : AnyObject]) throws -> T {
        // Make sure we actually have a value
        guard let rawValue = changes[changeKey] else { throw PGKVOError.nilChangeDictionary }

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

        throw PGKVOError.couldNotConvert(from: rawValue, to: T.self)
    }
    
}

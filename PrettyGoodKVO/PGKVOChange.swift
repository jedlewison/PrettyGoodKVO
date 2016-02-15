//
//  PGKVOChange.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/7/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

@objc public enum PGKVOChangeValueKind: Int, PGKVOChangeValueConvertible, CustomStringConvertible {
    case Initial
    case Change

    public var description: String {
        return "PGKVOChangeValueKind" + (self == .Change ? ".Change" : ".Initial")
    }
}

public struct PGKVOChange<Observed: NSObjectProtocol, Value> {

    /// The object that generated the change value
    public let observed: Observed

    /// The keyPath of the value that changed
    public let keyPath: String

    /// The value before the change, if the change kind is .Change, otherwise the initial value.
    public let old: Value

    /// The previous after the change, if the change kind is .Change, otherwise the initial value.
    public let new: Value

    /// Whether the change was the initial value (start of observation) or a subsequent change.
    public let kind: PGKVOChangeValueKind

    weak var observer: PGKVOObserving?

    /// Stop observing the keyPath of the object that generated the change.
    public func unobserveKeyPath() {
        guard let observer = observer,
            observed = observed as? NSObject else { return }
        observer.unobserve(observed, keyPath: keyPath)
    }

    /// Completely stop observing the object that generated the change.
    /// Note: Does not affect other observers.
    public func unobserveAllKeyPaths() {
        guard let observer = observer,
            observed = observed as? NSObject else { return }
        observer.unobserve(observed, keyPath: nil)
    }

}

/// Internal implementation details
extension PGKVOChange {

    init(observed: Observed, keyPath: String, initialValue: Value, observer: PGKVOObserving?) {
        self.init(observed: observed,
            keyPath: keyPath,
            old: initialValue,
            new: initialValue,
            kind: .Initial,
            observer: observer)
    }

    static func new<Observed: NSObjectProtocol, Value>(observed observed: Observed, keyPath: String, observer: PGKVOObserving?, changes: [String : AnyObject]?) -> PGKVOChange<Observed, Value>? {

        do {
            let parser = try PGKVOChangeParser(raw: changes, keyPath: keyPath)
            guard parser.hasChange() else { return nil }
            let old: Value = try parser.valueForChange(.Old)
            let new: Value = try parser.valueForChange(.New)
            return PGKVOChange<Observed, Value>(observed: observed, keyPath: keyPath, old: old, new: new, kind: .Change, observer: observer)
        } catch {
            debugPrint(error)
            return nil
        }

    }

    static func new<Observed: NSObjectProtocol, Value: OptionalType>(observed observed: Observed, keyPath: String, observer: PGKVOObserving?, changes: [String : AnyObject]?) -> PGKVOChange<Observed, Value>? {

        do {
            let parser = try PGKVOChangeParser(raw: changes, keyPath: keyPath)
            guard parser.hasChange() else { return nil }
            let old: Value = try parser.valueForChange(.Old)
            let new: Value = try parser.valueForChange(.New)
            return PGKVOChange<Observed, Value>(observed: observed, keyPath: keyPath, old: old, new: new, kind: .Change, observer: observer)
        } catch {
            debugPrint(error)
            return nil
        }

    }

}

extension PGKVOChange: CustomStringConvertible {
    public var description: String {
        let observing = "Observing: " + ((observed as? NSObject)?.description ?? "")
        return observing + " at keypath: " + keyPath + " \(kind) old: \(old) new: \(new)"
    }
}


//
//  PGKVOChange.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/7/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

public struct PGKVOChange<Observed: NSObject, Value>: CustomStringConvertible {

    /// The object that generated the change value
    public let observed: Observed

    /// The keyPath of the value that changed
    public let keyPath: String

    /// The newly observed value
    public var value: Value {
        return kind.value
    }

    /// Whether observation was of an initial value or a change.
    public let kind: PGKVOChangeKind<Value>

    private weak var observer: PGKVOObserving?

    /// Stop observing the keyPath of the object that generated the change.
    public func unobserveKeyPath() {
        guard let observer = observer else { return }
        observer.unobserve(observed, keyPath: keyPath)
    }

    /// Completely stop observing the object that generated the change.
    /// Note: Does not affect other observers.
    public func unobserveAllKeyPaths() {
        guard let observer = observer else { return }
        observer.unobserveAllKeyPaths(ofObject: observed)
    }

    public var description: String {
        let observing = "Observing: " + (observed.description ?? "")
        return observing + " at keypath: " + keyPath + " \(kind)"
    }

    internal init(observed: Observed, keyPath: String, kind: PGKVOChangeKind<Value>, observer: PGKVOObserving) {
        self.observed = observed
        self.keyPath = keyPath
        self.kind = kind
        self.observer = observer
    }
}

//
//  GenericPGKVOProxy.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/6/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

/// The `PGKVOObserving` protocol provides the core behavior for PrettyGoodKVO on Swift.
/// Simply declare any class (pure Swift or NSObject) to be PGKVOObserving and use the `observe`
/// and `unobserve` functions to start observing NSObjects.
public protocol PGKVOObserving: class { }

public extension PGKVOObserving {

    /// Observe `keyPath` of `object` with `initialValue,`
    /// and asserting that the observed object responds to the selector identified by the keypath.
    ///
    /// - Note: Unobservation happens either automatically when the object deallocates or the observer manually ends
    /// observation. The observer can safely deallocate without unobserving, however the `PGKVOProxy` observer
    /// will continue observing the object until the first change after the `PGKVOObserving` object deallocates.
    ///
    /// - Important: Only observations reflecting actual changes of value will be reported. To receive all observation
    /// notifications, see `NSObject+PGKVO.swift`.
    ///
    /// - Warning: Not all ObjectiveC classes are KVO compliant. You must verify that the object you are attempting
    /// to observe supports KVO or you will face trouble ahead.
    ///
    /// - Warning: `PGKVOObserving` does not currently support observing Foundation collection types.
    ///
    /// - Parameters:
    ///     - object: The object to observe. Must be an NSObject.
    ///     - keyPath: The keyPath to observe.
    ///     - initialValue: The initial value. Will be immediately returned in the closure.
    ///     - closure: A closure returning the `PGKVOChange` instance.
    /// - SeeAlso: `PGKVOChange` and `NSObject+PGKVO` for a discussion of PGKVO's proxy observer model.
    public func observe<Observed: NSObject, Value>(
        _ object: Observed,
        keyPath: String,
        initialValue: Value,
        closure: (change: PGKVOChange<Observed, Value>) -> ())
    {

        assert(Value.self != NSArray.self && Value.self != NSSet.self, "PGKVOObserving does not support observing Foundation collection types")

        let initialChange = PGKVOChange(observed: object,
                                        keyPath: keyPath,
                                        kind: .initial(initialValue),
                                        observer: self)
        closure(change: initialChange)

        object.pgkvo_addObserver(self, forKeyPath: keyPath, options: [.old, .new])
        { [weak self] observed, _, changes in
            guard let strongSelf = self,
                observed = observed as? Observed,
                changeKind = PGKVOChangeKind<Value>(changes: changes) else { return }

            let change = PGKVOChange(observed: observed,
                                     keyPath: keyPath,
                                     kind: changeKind,
                                     observer: strongSelf)
            closure(change: change)
            
        }

    }

    /// Stops `self` from observing specified `keyPath` of `object`.
    /// - Note: Specify `nil` for `keyPath` to stop `self` from observing the object completely.
    public func unobserve(_ object: NSObject, keyPath: String) {
        object.pgkvo_removeObserver(self, forKeyPath: keyPath, options: [.old, .new])
    }

    /// Same as `unobserve(anObject, keyPath: nil)`
    public func unobserveAllKeyPaths(ofObject object: NSObject) {
        object.pgkvo_removeObserver(self, forKeyPath: nil, options: [.old, .new])
    }
}

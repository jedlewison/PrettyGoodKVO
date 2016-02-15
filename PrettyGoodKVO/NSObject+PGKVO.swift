//
//  NSObject+PGKVO.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/2/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation
import ObjectiveC

/// Closure for handling PGKVO observations
/// - Parameters:
///     - observed: The object being observed
///     - observer: The observer (the `self` of the object that start observing)
///     - changes: The dictionary of KVO change notifications
///     - Note: In Objective-C, you may wish to cast observed to typeof(object) and observer to typeof(self).
public typealias PGKVOObservationClosure = (observed: AnyObject, observer: AnyObject, changes: [String : AnyObject]?) -> ()

/// Use these extensions to observe or unobserve objects from Objective-C or Swift.
/// When using Swift, you should generally use the `PGKVOObserving` protocol unless you need
/// access to the raw change dictionary, control over observation options, or are observing
/// Foundation collection types.

public extension NSObject {

    /// Start observing `object` at the given `keyPath` with specified `options`.
    ///
    ///
    /// - Parameters:
    ///     - object: The object to observe
    ///     - forKeyPath: The keyPath of the object to observe
    ///     - options: The KVO options to select
    ///     - closure: A block on which to handle changes.
    ///
    /// - Important: This method creates a proxy observer if one does not already exist. The proxy observer removes itself from
    ///   the observed object when the observed object deallocates or on the first change after all observers have removed
    ///   themselves, so you do not need to explicitly stop observation.
    ///
    /// - Warning: Not all ObjectiveC classes are KVO compliant. You must verify that the object you are attempting
    /// to observe supports KVO or you will face trouble ahead.
    ///
    /// - Note: Thread safe
    public func pgkvo_observe(object: AnyObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions, closure: PGKVOObservationClosure) {
        guard let object = object as? NSObject else { return }
        synchronized(object) {
            object.pgkvo_getOrCreateProxyObserver().addForClient(self, keyPath: keyPath, options: options, closure: closure)
        }
    }


    /// Stop observing `object` at the given `keyPath` for all options. Specify nil keyPath to stop all observation.
    /// - Parameters:
    ///     - object: The object to unobserve
    ///     - forKeyPath: The keyPath of the object to unobserve. Specify nil for all keypaths.
    /// - Note: Thread safe
    public func pgkvo_unobserve(object: AnyObject, forKeyPath keyPath: String?) {
        pgkvo_unobserve(object, forKeyPath: keyPath, options: nil)
    }

    /// Stop observing `object` at the given `keyPath` with specified `options`. Specify nil for options or keyPath to stop all observation.
    /// - Parameters:
    ///     - object: The object to unobserve
    ///     - forKeyPath: The keyPath of the object to unobserve. Specify nil for all keypaths.
    ///     - options: The KVO options to unobserve. Specify nil for all options. Has no effect if keyPath is nil.
    /// - Note: Thread safe
    public func pgkvo_unobserve(object: AnyObject, forKeyPath keyPath: String?, options: NSKeyValueObservingOptions?) {
        guard let object = object as? NSObject else { return }
        synchronized(object) {
            object.pgkvo_getProxyObserver()?.dropForClient(self, forKeyPath: keyPath, options: options)
        }
    }
    
    
}

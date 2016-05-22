//
//  NSObject+PGKVO_internal.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/14/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

private var keyForAssociatedProxyObject = #selector(NSObject.pgkvo_getProxyObserver)

/// Internal helpers for adding and removing observers and proxy observers.

internal extension NSObject {

    func pgkvo_addObserver(observer: AnyObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions, closure: PGKVOObservationClosure) {

        func getOrCreateProxyObserver() -> PGKVOProxy {
            if let kvo_observer = pgkvo_getProxyObserver() {
                return kvo_observer
            } else {
                let kvo_observer = PGKVOProxy(observedObject: self)
                objc_setAssociatedObject(self, &keyForAssociatedProxyObject, kvo_observer, .OBJC_ASSOCIATION_RETAIN)
                return kvo_observer
            }
        }

        getOrCreateProxyObserver().addForClient(observer, keyPath: keyPath, options: options, closure: closure)
    }

    func pgkvo_removeObserver(observer: AnyObject, forKeyPath keyPath: String?, options: NSKeyValueObservingOptions?) {
        pgkvo_getProxyObserver()?.dropForClient(observer, forKeyPath: keyPath, options: options)
    }

    @objc private func pgkvo_getProxyObserver() -> PGKVOProxy? {
        return objc_getAssociatedObject(self, &keyForAssociatedProxyObject) as? PGKVOProxy
    }
    
}

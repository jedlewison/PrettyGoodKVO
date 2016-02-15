//
//  NSObject+PGKVO_internal.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/14/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

private var keyForAssociatedProxyObject = Selector("pgkvo_getProxyObserver")

/// Internal helpers for adding and removing observers and proxy observers.

extension NSObject {

    /// Thread safe
    func pgkvo_addObserver(observer: AnyObject, forKeyPath keyPath: String, options: NSKeyValueObservingOptions, closure: PGKVOObservationClosure) {
        synchronized(self) {
            pgkvo_getOrCreateProxyObserver().addForClient(observer, keyPath: keyPath, options: options, closure: closure)
        }
    }

    /// Thread safe
    func pgkvo_removeObserver(observer: AnyObject, forKeyPath keyPath: String?, options: NSKeyValueObservingOptions?) {
        synchronized(self) {
            pgkvo_getProxyObserver()?.dropForClient(observer, forKeyPath: keyPath, options: options)
        }
    }

    /// Thread safe
    func pgkvo_removeProxyObserver(proxyObserver: PGKVOProxy) {
        synchronized(self) {
            if proxyObserver === pgkvo_getProxyObserver() {
                objc_setAssociatedObject(self, &keyForAssociatedProxyObject, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)            }
        }
    }

}

extension NSObject {

    /// Not thread safe
    func pgkvo_getProxyObserver() -> PGKVOProxy? {
        return objc_getAssociatedObject(self, &keyForAssociatedProxyObject) as? PGKVOProxy
    }

    /// Not thread safe
    func pgkvo_getOrCreateProxyObserver() -> PGKVOProxy {

        if let kvo_observer = pgkvo_getProxyObserver() {
            return kvo_observer
        } else {
            let kvo_observer = PGKVOProxy(observedObject: self)
            objc_setAssociatedObject(self, &keyForAssociatedProxyObject, kvo_observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return kvo_observer
        }
        
    }
    
}
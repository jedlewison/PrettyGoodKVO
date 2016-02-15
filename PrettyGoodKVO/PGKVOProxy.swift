//
//  PGKVOProxy.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/2/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation
import ObjectiveC

class PGKVOProxy: NSObject {

    /// Not thread safe
    private weak var weakObservedObject: NSObject?

    init(observedObject: NSObject) {
        weakObservedObject = observedObject
        nonretainedObservedObjectBox = NSValue(nonretainedObject: observedObject)
        super.init()
    }

    deinit {
        if let observedObject = unsafeUnretainedObservedObject {
            requests.dropAll().forEach {
                observedObject.removeObserver(self, forKeyPath: $0, context: &contextToken)
            }
        }
    }

    /// Not thread safe
    private var unsafeUnretainedObservedObject: NSObject? {
        return nonretainedObservedObjectBox?.nonretainedObjectValue as? NSObject
    }

    /// Not thread safe
    private var nonretainedObservedObjectBox: NSValue?

    /// Not thread safe
    private var requests = ObservationRequests()

    var contextToken = NSProcessInfo.processInfo().globallyUniqueString

    /// Adds thread safety
    override func observeValueForKeyPath(
        keyPath: String?,
        ofObject object: AnyObject?,
        change: [String : AnyObject]?,
        context: UnsafeMutablePointer<Void>)
    {
        guard let keyPath = keyPath, object = weakObservedObject else { return }
        synchronized(self) {
            let observationRequests = requests.requestsForKeyPath(keyPath, changeKeys: change?.keys.map { $0 } ?? [])
            observationRequests.forEach {
                if let observerClient = $0.client.client {
                    $0.closure(observed: object, observer: observerClient, changes: change)
                }
            }
            requests.dropNilClients().forEach {
                object.removeObserver(self, forKeyPath: $0, context: &contextToken)
            }
            if requests.allKeyPaths.count == 0 {
                object.pgkvo_removeProxyObserver(self)
            }
        }
    }

}

extension PGKVOProxy {

    /// Not thread safe (caller must guarantee)
    func dropForClient(
        client: AnyObject,
        forKeyPath keyPath: String?,
        options: NSKeyValueObservingOptions?)
    {
        requests.dropForClient(client, keyPath: keyPath, options: options).forEach {
            weakObservedObject?.removeObserver(self, forKeyPath: $0, context: &contextToken)
        }
        if requests.allKeyPaths.count == 0 {
            weakObservedObject?.pgkvo_removeProxyObserver(self)
        }
    }

    /// Not thread safe (caller must guarantee)
    func addForClient(
        client: AnyObject,
        keyPath: String,
        options: NSKeyValueObservingOptions,
        closure: PGKVOObservationClosure)
    {
        guard let observedObject = weakObservedObject else { return }
        requests.addForClient(client, keyPath: keyPath, options: options, closure: closure) {
            observedObject.addObserver(self, forKeyPath: keyPath, options: options, context: &contextToken)
        }
    }
}
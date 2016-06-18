//
//  PGKVOProxy.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/2/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation
import ObjectiveC

final internal class PGKVOProxy: NSObject {

    private let unmanagedObservedObject: Unmanaged<NSObject>
    private var unsafeUnretainedObject: NSObject {
        return unmanagedObservedObject.takeUnretainedValue()
    }

    init(observedObject: NSObject) {
        unmanagedObservedObject = Unmanaged.passUnretained(observedObject)
        super.init()
    }

    deinit {
        let observedKeyPaths = requests.allKeyPaths
        for keyPath in observedKeyPaths {
            unsafeUnretainedObject.removeObserver(self, forKeyPath: keyPath, context: &contextToken)
        }
    }

    private var requests = ObservationRequests()

    var contextToken = ProcessInfo.processInfo().globallyUniqueString

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: AnyObject?,
                 change: [NSKeyValueChangeKey : AnyObject]?,
                 context: UnsafeMutablePointer<Void>?)
    {
        guard let keyPath = keyPath, object = object as? NSObject else { return }

        dropNilClients()

        let requests = synchronized(self) {
            return self.requests
        }
        let observationRequests = requests.requestsForKeyPath(keyPath, changeKeys: change?.keys.map { $0 } ?? [])
        observationRequests.forEach {
            if let observerClient = $0.clientBox.client {
                $0.closure(observed: object, observer: observerClient, changes: change)
            }
        }
    }

    private func dropNilClients() {
        handleRequest {
            requests.dropNilClients()
        }
    }

    func dropForClient(
        _ client: AnyObject,
        forKeyPath keyPath: String?,
                   options: NSKeyValueObservingOptions?)
    {
        handleRequest {
            requests.dropForClient(client, keyPath: keyPath, options: options)
        }
    }

    func addForClient(
        _ client: AnyObject,
        keyPath: String,
        options: NSKeyValueObservingOptions,
        closure: PGKVOObservationClosure)
    {
        handleRequest {
            requests.addForClient(client, keyPath: keyPath, options: options, closure: closure)
        }
    }

    private func handleRequest(@noescape _ request: () -> KeyPathObservationAction) {
        synchronized(self) {
            switch request() {
            case .none:
                break
            case .observe(let keyPath, let options):
                unsafeUnretainedObject.addObserver(self, forKeyPath: keyPath, options: options, context: &contextToken)
            case .unobserve(let keyPaths):
                keyPaths.forEach {
                    unsafeUnretainedObject.removeObserver(self, forKeyPath: $0, context: &contextToken)
                }
            }
        }
    }
}

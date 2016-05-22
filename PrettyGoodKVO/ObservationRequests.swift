//
//  ObservationRequests.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/6/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

internal enum KeyPathObservationAction {
    case none
    case unobserve(Set<String>)
    case observe(String, NSKeyValueObservingOptions)
}

/// Models the requests for a single proxy observing an object on behalf of clients
internal struct ObservationRequests {

    private var count: Int {
        return _requests.count
    }

    var allKeyPaths: Set<String> {
        return Set(_requests.map { $0.keyPath } )
    }

    private var _requests = Set<ObservationRequest>()
    private var _requestsForClient: [ WeakClientBox : Set<ObservationRequest> ] = [ : ]
    private var _requestsForKeyPath: [ String : Set<ObservationRequest> ] = [ : ]


    // MARK: - Getting requests for handling observations

    @warn_unused_result(message="You must use the returned requests")
    func requestsForKeyPath(keyPath: String, changeKeys: [String]) -> [ObservationRequest] {

        let hasNewValue = changeKeys.contains(NSKeyValueChangeNewKey)
        let hasOldValue = changeKeys.contains(NSKeyValueChangeOldKey)
        let hasPriorValue = changeKeys.contains(NSKeyValueChangeNotificationIsPriorKey) // This is wrong-ish

        var options: [NSKeyValueObservingOptions] = []
        if hasNewValue { options += [.Prior, .New] }
        if hasOldValue { options += [.Old] }
        if hasPriorValue { options += [.Prior] }

        return _requestsForKeyPath[keyPath]?.filter { !$0.options.intersect(NSKeyValueObservingOptions(options)).isEmpty } ?? []
    }

    // MARK: - Dropping requests

    /// Drops requests that have been canceled or with nil clients and returns keypaths that are no longer being observed, if any
    @warn_unused_result(message="You must unobserve the returned keypaths")
    mutating func dropNilClients() -> KeyPathObservationAction {
        return dropRequests(_requests.filter { $0.clientBox.isNilClient } )
    }

    @warn_unused_result(message="You must unobserve the returned keypaths")
    mutating func dropForClient(client: AnyObject, keyPath: String?, options: NSKeyValueObservingOptions?) -> KeyPathObservationAction {

        func isMatchingRequest(request: ObservationRequest) -> Bool {
            switch (keyPath, options) {
            case let (keyPath?, options?):
                return request.keyPath == keyPath
                    && request.options == options
            case (nil, let options?):
                return request.options == options
            case (let keyPath?, nil):
                return request.keyPath == keyPath
            case (nil, nil):
                return true
            }
        }

        let clientBox = WeakClientBox(client)
        return dropRequests(_requestsForClient[clientBox]?.filter(isMatchingRequest) ?? [])

    }

    @warn_unused_result(message="You must unobserve the returned keypaths")
    private mutating func dropRequests(requestsToDrop: [ObservationRequest]) -> KeyPathObservationAction {
        guard requestsToDrop.count > 0 else { return .none }
        _requests.subtractInPlace(requestsToDrop)

        var requestsForClient: [ WeakClientBox : Set<ObservationRequest> ] = [ : ]
        var requestsForKeyPath: [ String : Set<ObservationRequest> ] = [ : ]

        for request in _requests {
            requestsForKeyPath.transformValueForKey(request.keyPath) { $0?.inserting(request) ?? Set([request]) }
            requestsForClient.transformValueForKey(request.clientBox) { $0?.inserting(request) ?? Set([request]) }
        }

        _requestsForClient = requestsForClient
        _requestsForKeyPath = requestsForKeyPath

        var keypathsToRemove = Set<String>()
        requestsToDrop.forEach { keypathsToRemove.insert($0.keyPath) }
        return .unobserve(keypathsToRemove.subtract(allKeyPaths))
    }

    // MARK: - Adding requests

    mutating func addForClient(client: AnyObject, keyPath: String, options: NSKeyValueObservingOptions, closure: PGKVOObservationClosure) -> KeyPathObservationAction {

        func needsObserverForRequest(request: ObservationRequest) -> Bool {
            return _requestsForKeyPath[keyPath]?
                .reduce(NSKeyValueObservingOptions()) { $0.union($1.options) }
                .intersect(options).isEmpty
                ?? true
        }

        let request = ObservationRequest(clientBox: WeakClientBox(client), keyPath: keyPath, options: options, closure: closure)

        let action: KeyPathObservationAction = needsObserverForRequest(request) ? .observe(keyPath, options) : .none

        _requests.insert(request)

        _requestsForKeyPath.transformValueForKey(keyPath) {
            $0?.inserting(request) ?? Set([request])
        }
        _requestsForClient.transformValueForKey(request.clientBox) {
            $0?.inserting(request) ?? Set([request])
        }
        
        return action
        
    }
    
}

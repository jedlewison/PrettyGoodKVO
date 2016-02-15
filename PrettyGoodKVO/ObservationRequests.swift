//
//  ObservationRequests.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/6/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

struct ObservationRequests {

    private var count: Int {
        return _requests.count
    }

    var allKeyPaths: Set<String> {
        return Set(_requests.map { $0.keyPath } )
    }

    private var _requests = Set<ObservationRequest>()
    private var _requestsForClient: [ WeakClientBox : Set<ObservationRequest> ] = [ : ]
    private var _requestsForKeyPath: [ String : Set<ObservationRequest> ] = [ : ]
}

/// Getting requests for handling observations
extension ObservationRequests {

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

}

/// Dropping requests
extension ObservationRequests {

    /// Drops all requests and returns keypaths that are no longer being observed, if any
    @warn_unused_result(message="You must unobserve the returned keypaths")
    mutating func dropAll() -> Set<String> {
        let allKeyPaths = self.allKeyPaths
        _requests.removeAll()
        _requestsForClient.removeAll()
        _requestsForKeyPath.removeAll()
        return allKeyPaths
    }

    /// Drops requests that have been canceled or with nil clients and returns keypaths that are no longer being observed, if any
    @warn_unused_result(message="You must unobserve the returned keypaths")
    mutating func dropNilClients() -> Set<String> {
        return dropRequests(_requests.filter { $0.client.isNilClient } )
    }

    @warn_unused_result(message="You must unobserve the returned keypaths")
    mutating func dropForClient(client: AnyObject, keyPath: String?, options: NSKeyValueObservingOptions?) -> Set<String> {

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

        let clientBox = WeakClientBox(client: client)
        return dropRequests(_requestsForClient[clientBox]?.filter(isMatchingRequest) ?? [])

    }

    @warn_unused_result(message="You must unobserve the returned keypaths")
    private mutating func dropRequests(requestsToDrop: [ObservationRequest]) -> Set<String> {
        guard requestsToDrop.count > 0 else { return [] }
        _requests.subtractInPlace(requestsToDrop)

        var requestsForClient: [ WeakClientBox : Set<ObservationRequest> ] = [ : ]
        var requestsForKeyPath: [ String : Set<ObservationRequest> ] = [ : ]

        for request in _requests {
            requestsForKeyPath.transformValueForKey(request.keyPath) { $0?.inserting(request) ?? Set([request]) }
            requestsForClient.transformValueForKey(request.client) { $0?.inserting(request) ?? Set([request]) }
        }

        _requestsForClient = requestsForClient
        _requestsForKeyPath = requestsForKeyPath

        var keypathsToRemove = Set<String>()
        requestsToDrop.forEach { keypathsToRemove.insert($0.keyPath) }
        return keypathsToRemove.subtract(allKeyPaths)
    }
    
    

}

/// Adding requests
extension ObservationRequests {

    mutating func addForClient(client: AnyObject, keyPath: String, options: NSKeyValueObservingOptions, closure: PGKVOObservationClosure, @noescape observationBlock: () -> ()) {

        func needsObserverForRequest(request: ObservationRequest) -> Bool {
            return _requestsForKeyPath[keyPath]?
                .reduce(NSKeyValueObservingOptions()) { $0.union($1.options) }
                .intersect(options).isEmpty
                ?? true
        }

        let request = ObservationRequest(client: client, keyPath: keyPath, options: options, closure: closure)

        let shouldCallAddObserverBlock = needsObserverForRequest(request)

        _requests.insert(request)

        _requestsForKeyPath.transformValueForKey(keyPath) {
            $0?.inserting(request) ?? Set([request])
        }
        _requestsForClient.transformValueForKey(request.client) {
            $0?.inserting(request) ?? Set([request])
        }
        
        if shouldCallAddObserverBlock {
            observationBlock()
        }
        
    }
    
}

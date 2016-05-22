//
//  WeakClientBox.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/4/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

internal struct WeakClientBox: Hashable {

    var isNilClient: Bool {
        return client == nil
    }

    weak var client: AnyObject?

    let hashValue: Int

    init(_ client: AnyObject) {
        hashValue = client.hashValue ?? 0
        self.client = client
    }

}

func ==(lhs: WeakClientBox, rhs: WeakClientBox) -> Bool {
    return lhs.client === rhs.client
}

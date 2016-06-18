//
//  File.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/2/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation
import ObjectiveC

internal func synchronized<ReturnType>(_ lockToken: AnyObject, @noescape action: () -> ReturnType) -> ReturnType {
    objc_sync_enter(lockToken)
    let result = action()
    objc_sync_exit(lockToken)
    return result
}

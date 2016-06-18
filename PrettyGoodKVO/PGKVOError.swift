//
//  PGKVOErrors.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/7/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

internal enum PGKVOError: ErrorProtocol {
    case nilChangeDictionary
    case couldNotConvert(from: Any?, to: Any)
    case couldNotTransform(from: Any, to: Any)
}

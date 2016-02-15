//
//  PGKVOErrors.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/7/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import Foundation

enum PGKVOError: ErrorType {
    case NilChangeDictionary
    case CouldNotConvert(from: Any?, to: Any)
    case CouldNotTransform(from: Any, to: Any)
}
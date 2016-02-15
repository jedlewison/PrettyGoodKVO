//
//  PrettyGoodKVOTests.swift
//  PrettyGoodKVOTests
//
//  Created by Jed Lewison on 2/2/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import XCTest
@testable import PrettyGoodKVO

class ObservableObject: NSObject {
    deinit {
        //debugPrint("ObservableObject did die",CFAbsoluteTimeGetCurrent())
    }

    var text: String {
        get {
            return synchronized(self) {
                return _text
            }
        }
        set {
            synchronized(self) {
                _text = newValue
            }
        }
    }
    var _text = "" {
        willSet {
            willChangeValueForKey("text")
        }

        didSet {
            didChangeValueForKey("text")
        }
    }

}
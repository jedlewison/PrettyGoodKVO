//
//  PGKVOValueConvertible.swift
//  PrettyGoodKVO
//
//  Created by Jed Lewison on 2/7/16.
//  Copyright © 2016 Magic App Factory. All rights reserved.
//

import MapKit

extension CLLocationCoordinate2D: PGKVOChangeNSValueConvertible {
    public init?(changeValue: NSValue) {
        self = changeValue.MKCoordinateValue
    }
}

extension MKCoordinateSpan: PGKVOChangeNSValueConvertible {
    public init?(changeValue: NSValue) {
        self = changeValue.MKCoordinateSpanValue
    }
}
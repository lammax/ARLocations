//
//  CLLocationCoordinate2D+adds.swift
//  AR Locations
//
//  Created by Mac on 19.07.2019.
//  Copyright © 2019 Lammax. All rights reserved.
//

import CoreLocation

extension CLLocationCoordinate2D: Equatable {
    
    static public func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return (lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude)
    }
    
    static public func !=(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return !(lhs == rhs)
    }
    
}

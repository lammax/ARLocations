//
//  MapSceneWorker.swift
//  AR Locations
//
//  Created by Mac on 06.07.2019.
//  Copyright (c) 2019 Lammax. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit
import MapKit

class MapSceneWorker {
  
    func makeRegion(maybeCenterCoordinate: CLLocationCoordinate2D?, maybeSpan: MKCoordinateSpan?) -> MKCoordinateRegion? {
        if let centerCoordinate = maybeCenterCoordinate {
            let defaultSpan : MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            // Specify the center position specified in MapView and the span declared with MKCoordinateSapn.
            return MKCoordinateRegion(
                center: centerCoordinate,
                span: maybeSpan ?? defaultSpan
            )
        } else {
            return nil
        }
    }
    
}

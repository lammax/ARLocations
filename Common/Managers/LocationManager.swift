//
//  LocationManager.swift
//  myPlace
//
//  Created by Mac on 02/05/2019.
//  Copyright © 2019 Unit. All rights reserved.
//

import CoreLocation

protocol LocationManagerDelegate: class {
    func locationManager(didLocationUpdate location: CLLocation)
    func locationManager(didHeadingUpdate heading: CLHeading)
    func locationManager(didErrorUpdate error: Error)
}

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let sharedInstance = LocationManager()
    weak var delegate: LocationManagerDelegate?
    
    var latestLocation: CLLocation? {
        didSet {
            if let location = latestLocation {
                self.delegate?.locationManager(didLocationUpdate: location)
            }
        }
    }
    var latestHeading : CLHeading? {
        didSet {
            if let heading = latestHeading {
                self.delegate?.locationManager(didHeadingUpdate: heading)
            }
        }
    }
    var latestError: Error? {
        didSet {
            if let error = latestError {
                self.delegate?.locationManager(didErrorUpdate: error)
            }
        }
    }

    let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = 10 // 1 meter
        locationManager.headingFilter = 10 // 1 degree
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.startUpdating()
    }
    
    deinit {
        print("Deinit YaLocationManager")
        stopUpdating()
    }
    
    func startUpdating() {
        self.locationManager.startUpdatingLocation()
        self.locationManager.startUpdatingHeading()
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Pick the location with best (= smallest value) horizontal accuracy
        if let location = (locations.sorted { $0.horizontalAccuracy < $1.horizontalAccuracy }.first) {
            self.latestLocation = location
            self.latestError = nil
        } else {
            self.latestLocation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        latestHeading = newHeading
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.startUpdating()
        } else {
            self.stopUpdating()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.latestError = error
    }
    
}

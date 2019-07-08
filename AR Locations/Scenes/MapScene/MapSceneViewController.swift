//
//  MapSceneViewController.swift
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

protocol MapSceneDisplayLogic: class {
    func displayLocation(viewModel: MapScene.Location.ViewModel)
}

class MapSceneViewController: UIViewController {
    var interactor: MapSceneBusinessLogic?
    var router: (NSObjectProtocol & MapSceneRoutingLogic & MapSceneDataPassing)?
    
    let motionManager: MotionManager = MotionManager.sharedInstance
    let locationManager: LocationManager = LocationManager.sharedInstance
    let exifManager: ExifManager = ExifManager.sharedInstance
    
    var isARSceneLoaded: Bool = false

    @IBOutlet weak var mapView: MKMapView!
    // MARK: Object lifecycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: Setup
  
    private func setup() {
        MapSceneConfigurator.sharedInstance.configure(viewController: self)
    }
  
    // MARK: Routing

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }

    // MARK: View lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        self.mapView.delegate = self
        self.motionManager.delegate = self
        self.locationManager.delegate = self
        self.motionManager.startUpdate()
        self.locationManager.startUpdating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        doOnDidLoad()
    }

    // MARK: Do something

    //@IBOutlet weak var nameTextField: UITextField!

    func doOnDidLoad() {

        if let location = self.router?.dataStore?.currentLocation {
            
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
            
            let horizontalAccuracy: Double = location.horizontalAccuracy
            let circleOverlay = MKCircle(center: location.coordinate,
                                         radius: horizontalAccuracy)
            self.mapView.addOverlay(circleOverlay)
            
        }
    }
    
    private func showLocation(location: CLLocation) {
        let request = MapScene.Location.Request(location: location)
        interactor?.showLocation(request: request)
    }

  
 }

extension MapSceneViewController: MapSceneDisplayLogic {
    
    func displayLocation(viewModel: MapScene.Location.ViewModel) {
        if let mapView = self.mapView {
            mapView.setCenter(viewModel.location.coordinate, animated: true)
            // Change the scale.
            // Specify magnification.
            let span : MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            // Specify the center position specified in MapView and the span declared with MKCoordinateSapn.
            let region : MKCoordinateRegion = MKCoordinateRegion(center: mapView.centerCoordinate, span: span)

            mapView.setRegion(region, animated: false)
        }
    }

}

extension MapSceneViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if let overlay = overlay as? MKCircle{
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.fillColor = UIColor.green
            circleRenderer.alpha = 0.2
            return circleRenderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
}

extension MapSceneViewController: MotionManagerDelegate {
    func motionManager(didSensorUpdate sensor: [SensorData : DataVector]) {
        DispatchQueue.main.async {
            if let gravityData: DataVector = sensor[SensorData.gravity] {
                if gravityData.y < -0.5  && !self.isARSceneLoaded {
                    self.isARSceneLoaded = true
                    self.router?.routeToARScene()
                }
            }
        }
    }
}

extension MapSceneViewController: LocationManagerDelegate {
    func locationManager(didLocationUpdate location: CLLocation) {
        self.showLocation(location: location)
    }
    
    func locationManager(didHeadingUpdate heading: CLHeading) {
        /*DispatchQueue.main.async {
            self.northLabel.text = "TNorth: \(self.exifManager.getHeading(heading: heading, north: .True))"
        }*/
    }
    
    func locationManager(didErrorUpdate error: Error) {
        /*DispatchQueue.main.async {
            self.showErrorAlert(error: error)
        }*/
    }
}
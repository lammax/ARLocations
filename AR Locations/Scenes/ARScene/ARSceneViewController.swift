//
//  ARSceneViewController.swift
//  AR Locations
//
//  Created by Mac on 05.07.2019.
//  Copyright (c) 2019 Lammax. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

//TODO
// - how to add locations from AR?

import UIKit
import SceneKit
import ARKit
import CoreLocation
import ARCoreLocation

protocol ARSceneDisplayLogic: class {
    func displayBackFromMap(viewModel: ARScene.BackFromMap.ViewModel)
    func displayStartAR(viewModel: ARScene.StartAR.ViewModel)
    func displaySaveLocation(viewModel: ARScene.SaveLocation.ViewModel)
}

class ARSceneViewController: UIViewController {
    var interactor: ARSceneBusinessLogic?
    var router: (NSObjectProtocol & ARSceneRoutingLogic & ARSceneDataPassing)?
    
    weak var motionManager: MotionManager? = MotionManager.sharedInstance
    weak var locationManager: LocationManager? = LocationManager.sharedInstance
    weak var exifManager: ExifManager? = ExifManager.sharedInstance
    var landmarker: ARLandmarker!
    
    var isMapSceneLoaded: Bool = false

    @IBOutlet weak var arSceneView: ARSCNView!
    @IBOutlet weak var gravityLabel: UILabel!
    @IBOutlet weak var northLabel: UILabel!
    @IBOutlet weak var gpsCoordinateLabel: UILabel!
    @IBOutlet weak var gpsAccuracyLabel: UILabel!
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
        
        ARSceneConfigurator.sharedInstance.configure(viewController: self)
        
    }
  
    // MARK: View lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Run the view's session
        arSceneView.session.run(.makeBaseConfiguration(), options: [.removeExistingAnchors, .resetTracking])
        
        //ARCoreLocation
        self.landmarker = ARLandmarker(view: ARSKView(), scene: InteractiveScene(), locationManager: CLLocationManager())
        self.landmarker.view.frame = self.arSceneView.bounds
        self.landmarker.scene.size = self.arSceneView.bounds.size
        self.arSceneView.addSubview(self.landmarker.view)
        
        self.isMapSceneLoaded = false
        self.motionManager?.delegate = self
        self.locationManager?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        arSceneView.session.pause()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        doOnDidLoad()
    }

    // MARK: Do something

    //@IBOutlet weak var nameTextField: UITextField!
    @IBAction func addLocationButtonClicked(_ sender: UIButton) {
        print("add location AR")
    }
    
    func doOnDidLoad() {
        let request = ARScene.StartAR.Request()
        interactor?.startAR(request: request)
    }
    
    private func runAR() {
        // Set the view's delegate
        arSceneView.delegate = self
        
        // Show statistics such as fps and timing information
        arSceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        arSceneView.scene = scene
        arSceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        arSceneView.autoenablesDefaultLighting = true
        arSceneView.session.delegate = self
    }
    
    private func saveLocation(location: CLLocation) {
        let request = ARScene.SaveLocation.Request(location: location)
        interactor?.saveLocation(request: request)
    }
    
 }

extension ARSceneViewController: ARSceneDisplayLogic {
    
    func displayBackFromMap(viewModel: ARScene.BackFromMap.ViewModel) {
    }

    func displayStartAR(viewModel: ARScene.StartAR.ViewModel) {
        self.runAR()
    }
    
    func displaySaveLocation(viewModel: ARScene.SaveLocation.ViewModel) {
        DispatchQueue.main.async {
            self.gpsCoordinateLabel.text = "GPS: \(self.exifManager?.getLocatonPoint(location: viewModel.location) ?? .zero)"
            self.gpsAccuracyLabel.text = "Accuracy: " + String(format: "%.2f", arguments: [self.exifManager?.getLocatonAccuracy(location: viewModel.location) ?? 0.0])
        }
    }
    
}

private extension ARConfiguration {
    static func makeBaseConfiguration() -> ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.isAutoFocusEnabled = true
        configuration.worldAlignment = .gravityAndHeading
        configuration.maximumNumberOfTrackedImages = 4
        //configuration.planeDetection = [ .horizontal, .vertical ]
        
        return configuration
    }
}

extension ARSceneViewController: ARSCNViewDelegate {
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
}

extension ARSceneViewController: ARSessionDelegate {
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // self.delegate?.arCameraManager(didFrameUpdate: frame, for: session)
    }
    
}

extension ARSceneViewController: MotionManagerDelegate {
    func motionManager(didSensorUpdate sensor: [SensorData : DataVector]) {
        if let gravityData: DataVector = sensor[SensorData.gravity] {
            if gravityData.y < -0.5 {
                self.gravityLabel.textColor = .blue
            } else if !self.isMapSceneLoaded{
                self.router?.routeToMapScene()
                self.isMapSceneLoaded = true
            }
            self.gravityLabel.text = self.motionManager?.dataToString(dataVector: gravityData, decimal: 3)
        }
    }
}

extension ARSceneViewController: LocationManagerDelegate {
    func locationManager(didLocationUpdate location: CLLocation) {
        self.saveLocation(location: location)
    }
    
    func locationManager(didHeadingUpdate heading: CLHeading) {
        DispatchQueue.main.async {
            self.northLabel.text = "TNorth: \(self.exifManager?.getHeading(heading: heading, north: .True) ?? 0.0)"
        }
    }
    
    func locationManager(didErrorUpdate error: Error) {
        DispatchQueue.main.async {
            self.showErrorAlert(error: error)
        }
    } 
}

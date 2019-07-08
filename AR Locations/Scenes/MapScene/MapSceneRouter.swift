//
//  MapSceneRouter.swift
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

@objc protocol MapSceneRoutingLogic {
    func routeToARScene()
}

protocol MapSceneDataPassing {
    var dataStore: MapSceneDataStore? { get }
}

class MapSceneRouter: NSObject, MapSceneRoutingLogic, MapSceneDataPassing {
    weak var viewController: MapSceneViewController?
    var dataStore: MapSceneDataStore?

    // MARK: Routing

    func routeToARScene() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "ARSceneViewController") as! ARSceneViewController
        var destinationDS = destinationVC.router!.dataStore!
        passDataToSomewhere(source: dataStore!, destination: &destinationDS)
        navigateToSomewhere(source: viewController!, destination: destinationVC)
    }

//     MARK: Navigation

    func navigateToSomewhere(source: MapSceneViewController, destination: ARSceneViewController) {
        self.viewController?.navigationController?.popViewController(animated: true)
    }

//     MARK: Passing data

    func passDataToSomewhere(source: MapSceneDataStore, destination: inout ARSceneDataStore) {
        destination.currentLocation = source.currentLocation
        destination.backFromMap = true
    }
}

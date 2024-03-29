//
//  StartSceneRouter.swift
//  AR Locations
//
//  Created by Mac on 05.07.2019.
//  Copyright (c) 2019 Lammax. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

@objc protocol StartSceneRoutingLogic {
    func routeToARScene()
}

protocol StartSceneDataPassing {
    var dataStore: StartSceneDataStore? { get }
}

class StartSceneRouter: NSObject, StartSceneRoutingLogic, StartSceneDataPassing {
    weak var viewController: StartSceneViewController?
    var dataStore: StartSceneDataStore?

    // MARK: Routing

    func routeToARScene() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationVC = storyboard.instantiateViewController(withIdentifier: "ARSceneViewController") as! ARSceneViewController
        var destinationDS = destinationVC.router!.dataStore!
        passDataToSomewhere(source: dataStore!, destination: &destinationDS)
        navigateToSomewhere(source: viewController!, destination: destinationVC)
    }

//     MARK: Navigation

    func navigateToSomewhere(source: StartSceneViewController, destination: ARSceneViewController) {
      self.viewController?.navigationController?.pushViewController(destination, animated: true)
    }

//     MARK: Passing data

    func passDataToSomewhere(source: StartSceneDataStore, destination: inout ARSceneDataStore) {
      //destination.name = source.name
    }
}

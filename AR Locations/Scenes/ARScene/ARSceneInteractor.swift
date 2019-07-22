//
//  ARSceneInteractor.swift
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
import CoreLocation
import MapKit

protocol ARSceneBusinessLogic {
    func startAR(request: ARScene.StartAR.Request)
    func backFromMap(request: ARScene.BackFromMap.Request)
    func saveLocation(request: ARScene.SaveLocation.Request)
}

protocol ARSceneDataStore {
    var currentLocation: CLLocation? { get set }
    var backFromMap: Bool { get set }
    var currentRegion: MKCoordinateRegion? { get set }
}

class ARSceneInteractor: ARSceneDataStore {
    
    weak var dbManager: DBManager? = DBManager.sharedInstance
    
    var presenter: ARScenePresentationLogic?
    var worker: ARSceneWorker?
    
    //MARK: DataStore
    var currentLocation: CLLocation?
    var backFromMap: Bool = false {
        didSet {
            if backFromMap {
                self.doBackFromMap()
            }
        }
    }
    var currentRegion: MKCoordinateRegion?
    // MARK: Do stuff
    
    private func doBackFromMap() {
        self.backFromMap = false
        let request = ARScene.BackFromMap.Request()
        self.backFromMap(request: request)
    }

}

extension ARSceneInteractor: ARSceneBusinessLogic {
    
    func startAR(request: ARScene.StartAR.Request) {
        //self.dbManager?.clearDB()
        let response = ARScene.StartAR.Response()
        presenter?.presentStartAR(response: response)
    }
    
    func backFromMap(request: ARScene.BackFromMap.Request) {
        let response = ARScene.BackFromMap.Response()
        presenter?.presentBackFromMap(response: response)
    }
    
    func saveLocation(request: ARScene.SaveLocation.Request) {
        self.currentLocation = request.location
        let response = ARScene.SaveLocation.Response(location: request.location)
        presenter?.presentSaveLocation(response: response)
    }

}

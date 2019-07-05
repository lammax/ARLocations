//
//  ARSceneConfigurator.swift
//  AR Locations
//
//  Created by Mac on 05.07.2019.
//  Copyright (c) 2019 Lammax. All rights reserved.
//
//  This file was generated by the Clean Swift HELM Xcode Templates
//  https://github.com/HelmMobile/clean-swift-templates

import UIKit

// MARK: Connect View, Interactor, and Presenter

class ARSceneConfigurator {
    // MARK: Object lifecycle
    
    static let sharedInstance = ARSceneConfigurator()
    
    private init() {}
    
    // MARK: Configuration
    
    func configure(viewController: ARSceneViewController) {
        let interactor = ARSceneInteractor()
        let presenter = ARScenePresenter()
        let router = ARSceneRouter()
        let worker = ARSceneWorker()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        interactor.worker = worker
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
}
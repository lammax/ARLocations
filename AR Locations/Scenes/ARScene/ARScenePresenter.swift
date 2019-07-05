//
//  ARScenePresenter.swift
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

protocol ARScenePresentationLogic {
    func presentSomething(response: ARScene.Something.Response)
}

class ARScenePresenter: ARScenePresentationLogic {
    weak var viewController: ARSceneDisplayLogic?

    // MARK: Do something

    func presentSomething(response: ARScene.Something.Response) {
        let viewModel = ARScene.Something.ViewModel()
        viewController?.displaySomething(viewModel: viewModel)
    }
    
}
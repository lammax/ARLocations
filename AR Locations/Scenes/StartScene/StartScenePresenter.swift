//
//  StartScenePresenter.swift
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

protocol StartScenePresentationLogic {
    func presentSomething(response: StartScene.Something.Response)
}

class StartScenePresenter: StartScenePresentationLogic {
    weak var viewController: StartSceneDisplayLogic?

    // MARK: Do something

    func presentSomething(response: StartScene.Something.Response) {
        let viewModel = StartScene.Something.ViewModel()
        viewController?.displaySomething(viewModel: viewModel)
    }
    
}
//
//  StartSceneViewController.swift
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
// - how to load and save map of annotations with given radius? DB =)


import UIKit

protocol StartSceneDisplayLogic: class {
    func displayStart(viewModel: StartScene.Start.ViewModel)
}

class StartSceneViewController: UIViewController {
    var interactor: StartSceneBusinessLogic?
    var router: (NSObjectProtocol & StartSceneRoutingLogic & StartSceneDataPassing)?

    @IBOutlet weak var startButton: UIButton!
    
    // MARK: Object lifecycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        //do deinit actions
    }

    // MARK: Setup
  
    private func setup() {
        StartSceneConfigurator.sharedInstance.configure(viewController: self)
    }
  
    // MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        doOnDidLoad()
    }

    // MARK: IBActions
    @IBAction func startButtonClicked(_ sender: UIButton) {
        let request = StartScene.Start.Request()
        interactor?.start(request: request)
    }
    
    // MARK: Do other stuff
    func doOnDidLoad() {
    }
  
 }

extension StartSceneViewController: StartSceneDisplayLogic {
    
    func displayStart(viewModel: StartScene.Start.ViewModel) {
        self.router?.routeToARScene()
    }

}

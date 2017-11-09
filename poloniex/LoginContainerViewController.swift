//
//  LoginContainerViewController.swift
//  poloniex
//
//  Created by Florin Uscatu on 9/2/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit

class LoginContainerViewController: UIViewController {

    @objc func exitVC() {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(LoginContainerViewController.exitVC))
        closeButton.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = closeButton
    }

}

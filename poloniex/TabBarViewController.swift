//
//  TabBarViewController.swift
//  poloniex
//
//  Created by Florin Uscatu on 9/2/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    @objc func goToLogin() {
        performSegue(withIdentifier: "logInSegue", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let logInBttn = UIBarButtonItem(title: "Log In", style: .plain, target: self, action: #selector(TabBarViewController.goToLogin))
        
        self.navigationItem.leftBarButtonItem = logInBttn
        
        let logoImage = UIImage(named: "poloniex")
        self.navigationItem.titleView = UIImageView(image: logoImage)
        
    }
}

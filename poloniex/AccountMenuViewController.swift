//
//  AccountMenuViewController.swift
//  poloniex
//
//  Created by Florin Uscatu on 9/3/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit
import Parchment

@IBDesignable class AccountMenuViewController: UIViewController {

    @IBInspectable var menuBackgroundColor:UIColor = UIColor.gray
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Array to keep track of controllers in page menu
        var controllerArray : [UIViewController] = []
        
        let balancesController : UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Balances")
        balancesController.title = "Balances"
        controllerArray.append(balancesController)
        
        let tradesController : UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Trades")
        tradesController.title = "Trades"
        controllerArray.append(tradesController)
        
        let ordersController : UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Orders")
        ordersController.title = "Orders"
        controllerArray.append(ordersController)
        
        let pagingViewController = FixedPagingViewController(viewControllers: controllerArray, options: PageMenuOptions())
        
        
        // Make sure you add the PagingViewController as a child view
        // controller and contrain it to the edges of the view.
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParentViewController: self)
        
    }
}

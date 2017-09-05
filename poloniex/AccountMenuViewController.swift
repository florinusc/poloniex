//
//  AccountMenuViewController.swift
//  poloniex
//
//  Created by Florin Uscatu on 9/3/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit
import PageMenu

@IBDesignable class AccountMenuViewController: UIViewController {

    @IBInspectable var menuBackgroundColor:UIColor = UIColor.gray
    
    var pageMenu : CAPSPageMenu?
    
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
        
        // Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
        // Example:
        let parameters: [CAPSPageMenuOption] = [
            .menuItemSeparatorWidth(0.0),
            .useMenuLikeSegmentedControl(true),
            .menuItemSeparatorPercentageHeight(0.1),
            .scrollMenuBackgroundColor(menuBackgroundColor)
        ]
        
        // Initialize page menu with controller array, frame, and optional parameters
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), pageMenuOptions: parameters)
        
        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
        self.view.addSubview(pageMenu!.view)
        
    }
    
    


}

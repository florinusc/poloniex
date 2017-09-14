//
//  TickerDetailMenuViewController.swift
//  poloniex
//
//  Created by Florin Uscatu on 9/8/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit
import PageMenu

@IBDesignable class TickerDetailMenuViewController: UIViewController {

    @IBInspectable var menuBackgroundColor:UIColor = UIColor.gray
    
    var coinData = NSDictionary()
    var coinPair = String()
    var chartDataArray: Array<ChartData> = []
    
    var pageMenu : CAPSPageMenu?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Array to keep track of controllers in page menu
        var controllerArray : [UIViewController] = []
        
        let chartsViewController : UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChartsViewController")
        chartsViewController.title = "Charts"
        controllerArray.append(chartsViewController)
        
        let orderBookViewController : UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrderBookViewController")
        orderBookViewController.title = "Order Book"
        controllerArray.append(orderBookViewController)
        
        let tradingViewController : UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TradingVC")
        tradingViewController.title = "New Trade"
        controllerArray.append(tradingViewController)
        
        let ordersViewController : UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TickerOrders")
        ordersViewController.title = "Orders"
        controllerArray.append(ordersViewController)
        
        let tickerTradesViewController : UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TickerTrades")
        tickerTradesViewController.title = "Trades"
        controllerArray.append(tickerTradesViewController)
        
        
        // Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
        // Example:
        
        guard let fontForMenu:UIFont = UIFont(name: "Helvetica", size: 12) else {return}
        
        let parameters: [CAPSPageMenuOption] = [
            .menuItemSeparatorWidth(0.0),
            .useMenuLikeSegmentedControl(true),
            .menuItemSeparatorPercentageHeight(0.1),
            .scrollMenuBackgroundColor(menuBackgroundColor),
            .titleTextSizeBasedOnMenuItemWidth(true),
            .menuItemFont(fontForMenu)
        ]
        
        self.addChildViewController(chartsViewController)
        self.addChildViewController(orderBookViewController)
        self.addChildViewController(tradingViewController)
        self.addChildViewController(ordersViewController)
        self.addChildViewController(tickerTradesViewController)
        
        // Initialize page menu with controller array, frame, and optional parameters
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), pageMenuOptions: parameters)
        

        
        // Lastly add page menu as subview of base view controller view
        // or use pageMenu controller in you view hierachy as desired
        self.view.addSubview(pageMenu!.view)
        
    }

}

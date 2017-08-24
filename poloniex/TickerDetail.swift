//
//  TickerDetail.swift
//  poloniex
//
//  Created by Florin Alexandru on 05/04/2017.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit

class TickerDetail: UIViewController, UITabBarDelegate {

    var coinData = NSDictionary()
    var coinPair = String()
    var chartDataArray: Array<ChartData> = []
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "containerSegue" {
            let pageViewController = segue.destination as! PageViewController
            pageViewController.coinPair = coinPair
            pageViewController.coinData = coinData
            
        }
    }
    
    @IBOutlet weak var tabBar: UITabBar!
    
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = coinPair
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        tabBar.selectedItem = tabBar.items?[0]
        
        
    }
}

//
//  TickerDetail.swift
//  poloniex
//
//  Created by Florin Alexandru on 05/04/2017.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit

class TickerDetail: UIViewController {

    var coinData = NSDictionary()
    var coinPair = String()
    var chartDataArray: Array<ChartData> = []
    
    var selectedPage = 0
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "containerSegue" {
            let pageViewController = segue.destination as! TickerDetailMenuViewController
            pageViewController.coinPair = coinPair
            pageViewController.coinData = coinData
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = coinPair
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

    }
}

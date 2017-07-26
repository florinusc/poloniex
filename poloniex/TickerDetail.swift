//
//  TickerDetail.swift
//  poloniex
//
//  Created by Florin Alexandru on 05/04/2017.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit

class TickerDetail: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var coinData = NSDictionary()
    var coinPair = String()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = coinPair
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinData.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if indexPath.row == 0 {
            cell = tableView.dequeueReusableCell(withIdentifier: "chartCell", for: indexPath) as! ChartCell
            
            
            
        } else if indexPath.row == 1 {
            cell = tableView.dequeueReusableCell(withIdentifier: "periodChartCell", for: indexPath) as! PeriodChartCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
            
            cell.textLabel?.text = coinData.allKeys[indexPath.row - 2] as? String
            cell.detailTextLabel?.text = coinData.allValues[indexPath.row - 2] as? String
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        }
        
        return 44
    }

}

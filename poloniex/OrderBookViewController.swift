//
//  OrderBookViewController.swift
//  poloniex
//
//  Created by Florin Uscatu on 8/24/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit

class OrderBookViewController: UITableViewController {

    var bids = Array<OrderBookEntry>()
    var asks = Array<OrderBookEntry>()
    
    var coinPair = String()
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let parentVC = self.parent as! PageViewController
        coinPair = parentVC.coinPair
        
        getAPIData(selectedCoinPair: coinPair)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(OrderBookViewController.loadAPIData), userInfo: nil, repeats: true)
    }
    
    func loadAPIData() {
        let parentVC = self.parent as! PageViewController
        coinPair = parentVC.coinPair
        
        getAPIData(selectedCoinPair: coinPair)
    }

    func getAPIData(selectedCoinPair: String) {
        let url = URL(string: "https://poloniex.com/public?command=returnOrderBook&currencyPair=\(selectedCoinPair)&depth=10")
        let request: NSMutableURLRequest = NSMutableURLRequest()
        request.url = url
        request.httpMethod = "GET"
        
        bids.removeAll()
        asks.removeAll()
        
        let session = URLSession.shared
        
        session.dataTask(with: url!, completionHandler: {
            (data, response, error) -> Void in
            
            if error == nil {
                DispatchQueue.main.async {
                    do {
                        if let jsonData = data {
                            let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! NSDictionary
                            
                            let bidsInJSON = json.value(forKey: "bids")!
                            
                            let bidsToPrint = (bidsInJSON as! NSArray)
                            
                            for item in bidsToPrint {
                                
                                let tempArray = item as! NSArray
                                
                                var price = String()
                                var amount = Double()
                                
                                for itemIn in tempArray {
                                    if let tempString = itemIn as? String {
                                        price = tempString
                                    } else if let tempNumb = itemIn as? Double {
                                        amount = tempNumb
                                    } else {
                                        print("found a different type")
                                    }
                                }
                                
                                self.bids.append(OrderBookEntry(price: price, amount: amount))
                                
                            }
                            
                            let asksInJSON = json.value(forKey: "asks")!
                            
                            let asksToPrint = (asksInJSON as! NSArray)
                            
                            for item in asksToPrint {
                                
                                let tempArray = item as! NSArray
                                
                                var price = String()
                                var amount = Double()
                                
                                for itemIn in tempArray {
                                    if let tempString = itemIn as? String {
                                        price = tempString
                                    } else if let tempNumb = itemIn as? Double {
                                        amount = tempNumb
                                    } else {
                                        print("found a different type")
                                    }
                                }
                                
                                self.asks.append(OrderBookEntry(price: price, amount: amount))
                                
                            }
                            
                            self.asks.reverse()
                            
                            self.tableView.reloadData()
                            
                        }
                    } catch let err {
                        print(err)
                    }
                }
            } else {
                print(error as Any)
            }
            
        }).resume()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        switch section {
        case 0:
            return asks.count
        case 1:
            return bids.count
        default:
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderBookCell", for: indexPath) as! OrderBookCell
            
            cell.priceLabel.text = String(asks[indexPath.row].price)
            cell.amountLabel.text = String(format: "%.8f", asks[indexPath.row].amount)
            
            cell.priceLabel.textColor = UIColor.red
            
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderBookCell", for: indexPath) as! OrderBookCell
            
            cell.priceLabel.text = String(bids[indexPath.row].price)
            cell.amountLabel.text = String(format: "%.8f", bids[indexPath.row].amount)
            
            cell.priceLabel.textColor = UIColor.green
            
            
            return cell
        }
        
        
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 25
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Asks"
        case 1:
            return "Bids"
        default:
            return ""
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        timer.invalidate()
    }
    
}

//
//  TickerOrdersViewController.swift
//  poloniex
//
//  Created by Florin Uscatu on 9/10/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit
import Alamofire

class TickerOrdersViewController: UITableViewController {
    

    var coinPair: String = ""
    
    var ordersArray: [OrderDetail] = []
    
    let newRefreshControl = UIRefreshControl()
    
    var alert = UIAlertController()
    
    var key: String {
        if UserDefaults.standard.value(forKey: "key") != nil {
            return UserDefaults.standard.value(forKey: "key") as! String
        } else {
            print("there is no key")
            return ""
        }
    }
    
    var secret: String {
        if UserDefaults.standard.value(forKey: "secret") != nil {
            return UserDefaults.standard.value(forKey: "secret") as! String
        } else {
            print("there is no secret")
            return ""
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        requestData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentVC = self.parent as? TickerDetailMenuViewController {
            coinPair = parentVC.coinPair
        }
        
        self.newRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.newRefreshControl.addTarget(self, action: #selector(TickerOrdersViewController.refresh), for: .allEvents)
        tableView.refreshControl = newRefreshControl
        
    }
    
    func refresh() {
        requestData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        newRefreshControl.endRefreshing()
    }
    
    
    func requestData() {
        
        let timeNowInt = Int((NSDate().timeIntervalSince1970)*500000)
        let timeNow = String(timeNowInt)
        
        if key != "" && secret != "" {
            guard let url = URL(string: "https://poloniex.com/tradingApi") else {return}
            
            let sign = "command=returnOpenOrders&currencyPair=\(coinPair)&nonce=\(timeNow)"
            
            let hmacSign: String = SweetHMAC(message: sign, secret: secret).HMAC(algorithm: .sha512)
            
            let headers: HTTPHeaders = ["key" : key, "sign" : hmacSign]
            let parameters: Parameters = ["command" : "returnOpenOrders", "currencyPair" : coinPair, "nonce" : timeNow]
            
            
            request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON(completionHandler: {
                response in
                
                if let jsonResponse = response.result.value as? NSArray {
                    
                    self.ordersArray.removeAll()
                    
                    for item in jsonResponse {
                                
                        if let orderDic = item as? NSDictionary {
                            
                            let newOrderDetail = OrderDetail(rate: (orderDic.value(forKey: "rate") as? String), amount: orderDic.value(forKey: "amount") as? String, total: orderDic.value(forKey: "total") as? String, orderNumber: orderDic.value(forKey: "orderNumber") as? String, type: "type" as String?)
                            
                            self.ordersArray.append(newOrderDetail)
                        }
                    }
                    
                    self.newRefreshControl.endRefreshing()
                    self.tableView.reloadData()
                    
                } else {
                    print("json is not readable")
                }
                
            })
            
        } else {
            print("can't show balances because the key and secret are nil")
            
            self.alert = UIAlertController(title: "Log in", message: "Please log in to access account information", preferredStyle: .alert)
            self.alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            self.newRefreshControl.endRefreshing()
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.ordersArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ordersArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TickerOrderCell", for: indexPath) as? OrderCell else {return UITableViewCell()}
        
        if !ordersArray.isEmpty {
            
            cell.amountCell.text = ordersArray[indexPath.row].amount
            cell.priceLabel.text = ordersArray[indexPath.row].rate
            cell.totalCell.text = ordersArray[indexPath.row].total
            cell.typeCell.text = ordersArray[indexPath.row].type
            
            switch ordersArray[indexPath.row].type {
            case "buy"?:
                cell.typeCell.textColor = UIColor.green
            case "sell"?:
                cell.typeCell.textColor = UIColor.red
            default:
                break
            }
            
        } else {
            print("there are no entries in the trades array")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TickerOrdersHeaderCell")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }


}

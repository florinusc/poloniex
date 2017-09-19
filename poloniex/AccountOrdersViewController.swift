//
//  AccountOrdersViewController.swift
//  poloniex
//
//  Created by Florin Uscatu on 9/8/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit
import Alamofire

struct Orders {
    let coinPair: String?
    let orderDetail: [OrderDetail]?
    
}

struct OrderDetail {
    let rate: String?
    let amount: String?
    let total: String?
    let orderNumber: String?
    let type: String?
}


class AccountOrdersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var ordersArray: [Orders] = []
    
    let refreshControl = UIRefreshControl()
    
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
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(AccountTradesViewController.refresh), for: .allEvents)
        tableView.refreshControl = refreshControl
        
    }
    
    func refresh() {
        requestData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        refreshControl.endRefreshing()
    }

    
    func requestData() {
        
        let timeNowInt = Int((NSDate().timeIntervalSince1970)*500000)
        let timeNow = String(timeNowInt)
        
        if key != "" && secret != "" {
            guard let url = URL(string: "https://poloniex.com/tradingApi") else {return}
            
            let sign = "command=returnOpenOrders&currencyPair=all&nonce=\(timeNow)"
            
            let hmacSign: String = SweetHMAC(message: sign, secret: secret).HMAC(algorithm: .sha512)
            
            let headers: HTTPHeaders = ["key" : key, "sign" : hmacSign]
            let parameters: Parameters = ["command" : "returnOpenOrders", "currencyPair" : "all", "nonce" : timeNow]
            
            
            request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON(completionHandler: {
                response in
                
                if let jsonResponse = response.result.value as? NSDictionary {
                    
                    self.ordersArray.removeAll()
                    
                    for item in jsonResponse {
                    
                        var tempOrderDetailArray: [OrderDetail] = []
                        
                        if let orderInfo = item.value as? NSArray {
                        
                            for order in orderInfo {
                            
                                if let orderDic = order as? NSDictionary {
                                    
                                    let newOrderDetail = OrderDetail(rate: (orderDic.value(forKey: "rate") as? String), amount: orderDic.value(forKey: "amount") as? String, total: orderDic.value(forKey: "total") as? String, orderNumber: orderDic.value(forKey: "orderNumber") as? String, type: "type" as String?)
                                    
                                    tempOrderDetailArray.append(newOrderDetail)
                                }
                            }
                            
                        }
                        
                        if !tempOrderDetailArray.isEmpty {
                        
                            self.ordersArray.append(Orders(coinPair: item.key as? String, orderDetail: tempOrderDetailArray))
                        }
                    }
                    
                    self.refreshControl.endRefreshing()
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
            self.refreshControl.endRefreshing()
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.ordersArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let numberOfRowsToReturn = ordersArray[section].orderDetail?.count {
            return numberOfRowsToReturn
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as? OrderCell else {return UITableViewCell()}
        
        if !ordersArray.isEmpty {
            
            if let arr: [OrderDetail] = ordersArray[indexPath.section].orderDetail {
                
                cell.amountCell.text = arr[indexPath.row].amount
                cell.priceLabel.text = arr[indexPath.row].rate
                cell.totalCell.text = arr[indexPath.row].total
                cell.typeCell.text = arr[indexPath.row].type
                
                switch arr[indexPath.row].type {
                case "buy"?:
                    cell.typeCell.textColor = UIColor.green
                case "sell"?:
                    cell.typeCell.textColor = UIColor.red
                default:
                    break
                }
                
            } else {
                print("index out of range")
            }
            
        } else {
            print("there are no entries in the trades array")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrdersHeaderCell")
        
        let coinPairLabel = UILabel(frame: CGRect(x: 5, y: 5, width: 120, height: 20))
        
        coinPairLabel.text = self.ordersArray[section].coinPair
        
        cell?.addSubview(coinPairLabel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

}

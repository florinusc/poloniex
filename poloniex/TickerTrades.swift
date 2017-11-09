//
//  TickerTrades.swift
//  poloniex
//
//  Created by Florin Uscatu on 9/11/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit
import Alamofire

class TickerTrades: UITableViewController {

    var coinPair:String = ""
    
    let newRefreshControl = UIRefreshControl()
    
    var alert = UIAlertController()
    
    var tradesArray: [TradeDetail] = []
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        retrieveData()
        self.tableView.reloadData()

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parent = self.parent as? TickerDetailMenuViewController {
            coinPair = parent.coinPair
            retrieveData()
        }
        
        newRefreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        newRefreshControl.addTarget(self, action: #selector(TickerTrades.refresh), for: .allEvents)
        tableView.refreshControl = newRefreshControl
        
    }
    
    func retrieveData() {
        
        let timeNowInt = Int((NSDate().timeIntervalSince1970)*500000)
        let timeNow = String(timeNowInt)
        
        if key != "" && secret != "" {
            guard let url = URL(string: "https://poloniex.com/tradingApi") else {return}
            
            var timeInterval = DateComponents()
            timeInterval.year = -1
            var aYearAgoUNIXTime:String = ""
            if let aYearAgo = Calendar.current.date(byAdding: timeInterval, to: Date()) {
                aYearAgoUNIXTime = String(describing: Int(aYearAgo.timeIntervalSince1970))
            }
            
            let sign = "command=returnTradeHistory&currencyPair=\(coinPair)&limit=10000&nonce=\(timeNow)&start=\(aYearAgoUNIXTime)"
            
            let hmacSign: String = SweetHMAC(message: sign, secret: secret).HMAC(algorithm: .sha512)
            
            let headers: HTTPHeaders = ["key" : key, "sign" : hmacSign]
            let parameters: Parameters = ["currencyPair" : coinPair, "limit" : "10000", "start" : aYearAgoUNIXTime, "nonce" : timeNow, "command" : "returnTradeHistory"]
            
            print(parameters)
            print(sign)
            
            request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON(completionHandler: {
                response in
                
                if let jsonResponse = response.result.value as? NSArray {
                    
                    self.tradesArray.removeAll()
                    
                    for item in jsonResponse {
                        
                        if let tradeDic = item as? NSDictionary {
                            
                            self.tradesArray.append(TradeDetail(globalTraderID: tradeDic.value(forKey: "globalTraderID") as? String,
                                                                    tradeID: tradeDic.value(forKey: "tradeID") as? String,
                                                                    date: tradeDic.value(forKey: "date") as? String,
                                                                    rate: tradeDic.value(forKey: "rate") as? String,
                                                                    amount: tradeDic.value(forKey: "amount") as? String,
                                                                    total: tradeDic.value(forKey: "total") as? String,
                                                                    fee: tradeDic.value(forKey: "fee") as? String,
                                                                    orderNumber: tradeDic.value(forKey: "orderNumber") as? String,
                                                                    type: tradeDic.value(forKey: "type") as? String,
                                                                    category: tradeDic.value(forKey: "category") as? String))
                        }
                        
                    }
                    
                    self.newRefreshControl.endRefreshing()
                    self.tableView.reloadData()
                    
                } else {
                    print("json is not readable")
                    print(response)
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tradesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TickertradeCell", for: indexPath) as? TradeCell else {return UITableViewCell()}
        
        if !tradesArray.isEmpty {
            
            cell.amountLabel.text = tradesArray[indexPath.row].amount
            cell.dateLabel.text = tradesArray[indexPath.row].date
            cell.priceBTCLabel.text = tradesArray[indexPath.row].rate
            cell.totalBTCLabel.text = tradesArray[indexPath.row].total
            cell.typeLabel.text = tradesArray[indexPath.row].type
            
            switch tradesArray[indexPath.row].type {
            case "buy"?:
                cell.typeLabel.textColor = UIColor.green
            case "sell"?:
                cell.typeLabel.textColor = UIColor.red
            default:
                break
            }
            
        } else {
            print("there are no entries in the trades array")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TickerTradesHeaderCell")
        
        return cell
    }
    
    @objc func refresh() {
        
        retrieveData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        newRefreshControl.endRefreshing()
    }

}

//
//  AccountTradesViewController.swift
//  poloniex
//
//  Created by Florin Uscatu on 9/5/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit
import Alamofire
import Gloss

struct Trades {
    let coinPair: String?
    let tradeDetail: [TradeDetail]?
    
}

struct TradeDetail {
    let globalTraderID: String?
    let tradeID: String?
    let date: String?
    let rate: String?
    let amount: String?
    let total: String?
    let fee: String?
    let orderNumber: String?
    let type: String?
    let category: String?
}

class AccountTradesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
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
    
    var tradesArray: [Trades] = []
    
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
            
            let sign = "command=returnTradeHistory&currencyPair=all&limit=10000&nonce=\(timeNow)&start=\(aYearAgoUNIXTime)"
            
            let hmacSign: String = SweetHMAC(message: sign, secret: secret).HMAC(algorithm: .sha512)
            
            let headers: HTTPHeaders = ["key" : key, "sign" : hmacSign]
            let parameters: Parameters = ["command" : "returnTradeHistory", "currencyPair" : "all", "limit" : "10000", "nonce" : timeNow, "start" : aYearAgoUNIXTime]
            
            
            request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON(completionHandler: {
                response in
                
                if let jsonResponse = response.result.value as? NSDictionary {
                    
                    self.tradesArray.removeAll()
                    
                    for item in jsonResponse {
                        
                        var tempTradeDetailArray: [TradeDetail] = []
                        
                        if let tradeInfo = item.value as? NSArray {
                        
                            for trade in tradeInfo {
                                if let tradeDic = trade as? NSDictionary {
                                    
                                    tempTradeDetailArray.append(TradeDetail(globalTraderID: tradeDic.value(forKey: "globalTraderID") as? String,
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
                        }
                        self.tradesArray.append(Trades(coinPair: item.key as? String, tradeDetail: tempTradeDetailArray))
                        
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
            //self.present(self.alert, animated: true, completion: nil)
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            self.refreshControl.endRefreshing()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.tradesArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let numberOfRowsToReturn = tradesArray[section].tradeDetail?.count {
            return numberOfRowsToReturn
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "tradeCell", for: indexPath) as? TradeCell else {return UITableViewCell()}
        
        if !tradesArray.isEmpty {
        
            if let arr: [TradeDetail] = tradesArray[indexPath.section].tradeDetail {
            
                cell.amountLabel.text = arr[indexPath.row].amount
                cell.dateLabel.text = arr[indexPath.row].date
                cell.priceBTCLabel.text = arr[indexPath.row].rate
                cell.totalBTCLabel.text = arr[indexPath.row].total
                cell.typeLabel.text = arr[indexPath.row].type
            
                switch arr[indexPath.row].type {
                case "buy"?:
                    cell.typeLabel.textColor = UIColor.green
                case "sell"?:
                    cell.typeLabel.textColor = UIColor.red
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TradesHeaderCell")
        
        let coinPairLabel = UILabel(frame: CGRect(x: 5, y: 5, width: 120, height: 20))
        
        coinPairLabel.text = self.tradesArray[section].coinPair
        
        cell?.addSubview(coinPairLabel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        retrieveData()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(AccountTradesViewController.refresh), for: .allEvents)
        tableView.refreshControl = refreshControl
        
    }
    
    func refresh() {
    
        retrieveData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        refreshControl.endRefreshing()
    }


}

//
//  TradingViewController.swift
//  poloniex
//
//  Created by Florin Uscatu on 9/8/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit
import Alamofire
import JSSAlertView


class TradingViewController: UITableViewController {
    
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
    
    var orderType: String = "Buy"
    var coinPair: String = ""
    
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var placeOrderBttnOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let parentVC = self.parent as? TickerDetailMenuViewController {
            coinPair = parentVC.coinPair
            
            let mainCoin = self.coinPair.components(separatedBy: "_")
            
            if orderType == "Buy" {
                requestCurrentBalance(coin: mainCoin[0])
            } else if orderType == "Sell" {
                requestCurrentBalance(coin: mainCoin[1])
            } else {
                print("problem with order type")
            }
            
            
            print("coin pair is: \(coinPair)")
        }
        
        print("coin balance is \(currentBalance)")
        
        placeOrderBttnOutlet.layer.cornerRadius = 8.0
        
    }
    
    
    @IBAction func transactionTypeAction(_ sender: UISegmentedControl) {
        let mainCoin = self.coinPair.components(separatedBy: "_")
        if sender.selectedSegmentIndex == 0 {
            orderType = "Buy"
            sender.tintColor = UIColor.green
            requestCurrentBalance(coin: mainCoin[0])
        } else {
            orderType = "Sell"
            sender.tintColor = UIColor.red
            requestCurrentBalance(coin: mainCoin[1])
        }
        
        self.tableView.reloadData()
    }
    
    
    @IBAction func placeOrderBttnAction(_ sender: UIButton) {
    
        let mainCoin = self.coinPair.components(separatedBy: "_")
        
        guard let rate: String = priceTextField.text else {return}
        guard let amount: String = amountTextField.text else {return}
        
        print("the order type is: \(orderType) price: \(rate) amount \(amount)")
        
        let alertView = JSSAlertView().show(self, title: "New Order", text: "Are you sure you want to place this order?", noButtons: false, buttonText: "Yes", cancelButtonText: "Cancel", color: .gray, iconImage: UIImage())
        alertView.addAction(confirmOrder)
    }
    
    func confirmOrder(){
        print("order is confirmed")
    }
    
    func postOrder(type: String, price: String, amount: String) {
    
        let timeNowInt = Int((NSDate().timeIntervalSince1970)*500000)
        let timeNow = String(timeNowInt)
        
        if key != "" && secret != "" {
            guard let url = URL(string: "https://poloniex.com/tradingApi") else {return}
            
            let sign = "command=\(orderType)&currencyPair=\(coinPair)&rate=\(price)&amount=\(amount)&nonce=\(timeNow)"
            
            let hmacSign: String = SweetHMAC(message: sign, secret: secret).HMAC(algorithm: .sha512)
            
            let headers: HTTPHeaders = ["key" : key, "sign" : hmacSign]
            let parameters: Parameters = ["command" : orderType, "currencyPair" : coinPair, "rate" : price , "amount" : amount , "nonce" : timeNow]
            
            
            request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON(completionHandler: {
                response in
                
                if let jsonResponse = response.result.value as? NSDictionary {
                    
                    print (jsonResponse)
                    
                } else {
                    print("json is not readable")
                }
                
            })
            
        } else {
            print("can't show balances because the key and secret are nil")
            
            JSSAlertView().show(self, title: "Log in", text: "Please log in before trying to place an order", noButtons: false, buttonText: nil, cancelButtonText: "Ok", color: .gray)
            
            //self.alert = UIAlertController(title: "Log in", message: "Please log in to access account information", preferredStyle: .alert)
            //self.alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            //UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func requestCurrentBalance(coin: String) {
    
        let timeNowInt = Int((NSDate().timeIntervalSince1970)*500000)
        let timeNow = String(timeNowInt)
        
        if key != "" && secret != "" {
            
            guard let url = URL(string: "https://poloniex.com/tradingApi") else {return}
            
            let sign = "command=returnBalances&nonce=\(timeNow)"
            
            let hmacSign: String = SweetHMAC(message: sign, secret: secret).HMAC(algorithm: .sha512)
            
            let headers: HTTPHeaders = ["key" : key, "sign" : hmacSign]
            let parameters: Parameters = ["command" : "returnBalances", "nonce" : timeNow]
            
            request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON(completionHandler: {
                response in
                
                if let jsonResponse = response.result.value as? NSDictionary {
                    
                    if let balance = jsonResponse.value(forKey: coin) {
                    
                        self.currentBalance = String(describing: balance)
                    
                    } else {
                        print("cannot assign value to current balance")
                    }
                }
            })
            
        } else {
            currentBalance = "Not logged in"
        }
    
    }
    
    var currentBalance: String = "" {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let mainCoin = self.coinPair.components(separatedBy: "_")
        
        if currentBalance == "Not logged in" {
            return currentBalance
        } else {
            if orderType == "Buy" {
                return "Your current balance is: \(currentBalance) \(mainCoin[0])"
            } else {
                return "Your current balance is: \(currentBalance) \(mainCoin[1])"
            }
        }
    }
    
}

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
import CryptoSwift


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

        //Text Field Delegate
        priceTextField.delegate = self
        amountTextField.delegate = self
        
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
        }
        
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
        
        if currentBalance == "Not logged in" {
            JSSAlertView().show(self, title: "Warning", text: "Please log in before trying to place an order", noButtons: false, buttonText: "Ok", color: .red, iconImage: UIImage())
        } else {
            if rate != "" && amount != "" {
                let alertView = JSSAlertView().show(self, title: "New Order", text: "Are you sure you want to \(orderType.lowercased()) \(amount) \(mainCoin[1]) at \(rate) \(mainCoin[0])", noButtons: false, buttonText: "Yes", cancelButtonText: "Cancel", color: UIColor.white, iconImage: UIImage())
                alertView.addAction(confirmOrder)
            } else {
                JSSAlertView().show(self, title: "Warning", text: "Please fill in price and amount", noButtons: false, buttonText: "Ok", color: .red, iconImage: UIImage())
            }
        }
    }
    
    func confirmOrder() {
        guard let rate: String = priceTextField.text else {return}
        guard let amount: String = amountTextField.text else {return}
        postOrder(type: orderType.lowercased(), price: rate, amount: amount)
        
    }
    
    func postOrder(type: String, price: String, amount: String) {
    
        let timeNowInt = Int((NSDate().timeIntervalSince1970)*500000)
        let timeNow = String(timeNowInt)
        
        if key != "" && secret != "" {
            guard let url = URL(string: "https://poloniex.com/tradingApi") else {return}
            
            let sign = "nonce=\(timeNow)&command=\(orderType.lowercased())&currencyPair=\(coinPair)&rate=\(price)&amount=\(amount)"
            let parameters: Parameters = ["nonce" : timeNow, "command" : orderType.lowercased(), "currencyPair" : coinPair, "rate" : price, "amount" : amount]
            let hmacSign: String = SweetHMAC(message: sign, secret: secret).HMAC(algorithm: .sha512)
            
            var components = URLComponents()
            let queryItems: [URLQueryItem] = [URLQueryItem(name: "amount", value: amount),
                                              URLQueryItem(name: "command", value: orderType.lowercased()),
                                              URLQueryItem(name: "nonce", value: timeNow),
                                              URLQueryItem(name: "currencyPair", value: coinPair),
                                              URLQueryItem(name: "rate", value: price),
                                              ]
            
            components.queryItems = queryItems
            guard let query = components.query else {return}
            
            guard let httpBody = query.data(using: .utf8) else {return}
            
            let signature = try? HMAC(key: secret, variant: .sha512)
                .authenticate(Array(httpBody))
                .map { String(format: "%02X", $0) }
                .joined()

            let headers: HTTPHeaders = ["Key" : key, "Sign" : signature!]
            
            print(parameters)
            print(signature!)
            print(hmacSign)
            
            var request = URLRequest(url: URL(string: "https://poloniex.com/tradingApi")!)
            request.httpMethod = "POST"
            request.httpBody = httpBody
            
            request.setValue(key, forHTTPHeaderField: "Key")
            request.setValue(signature, forHTTPHeaderField: "Sign")
            
            let task = URLSession.shared.dataTask(with: request) {
                (data, response, error) -> Void in
                
                if error == nil {
                    
                    print(data)
                    print(response)
                } else {
                    print(error)
                }
                
            }
            
            task.resume()
            
//            request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON(completionHandler: {
//                response in
//
//                print("the response is \(response)")
//
//                if let jsonResponse = response.result.value as? NSDictionary {
//
//                    print(jsonResponse)
//
//                    if let orderNumber = jsonResponse["orderNumber"] as? String {
//
//                        print("placed order with id: " + orderNumber)
//
//                        JSSAlertView().show(self, title: "Success", text: "The order has been placed", noButtons: false, buttonText: nil, cancelButtonText: "Ok", color: .white)
//
//                        self.priceTextField.text = ""
//                        self.amountTextField.text = ""
//
//                    } else {
//                        JSSAlertView().show(self, title: "Failure", text: "Not able to place order", noButtons: false, buttonText: nil, cancelButtonText: "Ok", color: .red)
//                    }
//                } else {
//                    print("json is not readable")
//                    JSSAlertView().show(self, title: "Failure", text: "Not able to place order", noButtons: false, buttonText: nil, cancelButtonText: "Ok", color: .red)
//                }
//
//            })
//
        } else {
            print("can't show balances because the key and secret are nil")

            JSSAlertView().show(self, title: "Log in", text: "Please log in before trying to place an order", noButtons: false, buttonText: nil, cancelButtonText: "Ok", color: .gray)
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

extension TradingViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let allowedCharacters = "0123456789."
        return allowedCharacters.contains(string) || range.length == 1
    }
    
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

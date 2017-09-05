//
//  AccountBalancesViewController.swift
//  poloniex
//
//  Created by Florin Uscatu on 9/4/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit
import Alamofire
import CryptoSwift

struct Balance {
    var coin: String?
    var amount: Double?
}

class AccountBalancesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var balanceArray: [Balance] = []
    
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
    
    func retrieveBalances() {
        
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
                
                let jsonResponse = response.result.value as! NSDictionary
                
                for item in jsonResponse {
                    if Double("\(item.value)") != 0.0 {
                        self.balanceArray.append(Balance(coin: "\(item.key)", amount: Double("\(item.value)")!))
                        
                        print("\(item.key) - \(item.value)")
                    }
                }
                
                self.tableView.reloadData()
                
            })
            
        } else {
            print("can't show balances because the key and secret are nil")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return balanceArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "balanceCell", for: indexPath) as! BalanceCell
        cell.coinName.text = balanceArray[indexPath.row].coin
        
        if let amount = balanceArray[indexPath.row].amount {
            cell.amountLabel.text = String(amount)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BalancesHeaderCell")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        retrieveBalances()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
    }
}

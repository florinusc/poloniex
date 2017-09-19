//
//  AccountBalancesViewController.swift
//  poloniex
//
//  Created by Florin Uscatu on 9/4/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit
import Alamofire
//import CryptoSwift

struct Balance {
    var coin: String?
    var amount: Double?
    var btcValue: Double?
}

class AccountBalancesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var totalBTCAmount = Double(0)
    
    var balanceArray: [Balance] = []
    
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
    
    var coinSortState = false
    var amountSortState = false
    var btcValueSortState = false
    
    @IBAction func sortByName(_ sender: UIButton) {
        if !coinSortState {
            balanceArray.sort {$0.coin! < $1.coin!}
            
            self.tableView.reloadData()
            
            coinSortState = true
        } else {
            balanceArray.sort {$0.coin! > $1.coin!}
            
            self.tableView.reloadData()
            
            coinSortState = false
        }
    }
    
    @IBAction func sortByAmount(_ sender: UIButton) {
        if !amountSortState {
            balanceArray.sort {$0.amount! < $1.amount!}
            
            self.tableView.reloadData()
            
            amountSortState = true
        } else {
            balanceArray.sort {$0.amount! > $1.amount!}
            
            self.tableView.reloadData()
            
            amountSortState = false
        }
    }
    
    
    @IBAction func sortByBtcValue(_ sender: UIButton) {
        if !btcValueSortState {
            balanceArray.sort {$0.btcValue! < $1.btcValue!}
            
            self.tableView.reloadData()
            
            btcValueSortState = true
        } else {
            balanceArray.sort {$0.btcValue! > $1.btcValue!}
            
            self.tableView.reloadData()
            
            btcValueSortState = false
        }
    }
    
    func retrieveBalances() {
        
        let timeNowInt = Int((NSDate().timeIntervalSince1970)*500000)
        let timeNow = String(timeNowInt)

        if key != "" && secret != "" {
            guard let url = URL(string: "https://poloniex.com/tradingApi") else {return}
            
            let sign = "command=returnCompleteBalances&nonce=\(timeNow)"
            
            let hmacSign: String = SweetHMAC(message: sign, secret: secret).HMAC(algorithm: .sha512)
            
            let headers: HTTPHeaders = ["key" : key, "sign" : hmacSign]
            let parameters: Parameters = ["command" : "returnCompleteBalances", "nonce" : timeNow]
            
            print("sign is: \(sign)")
            print("parameters are: \(parameters)")
            
            request(url, method: .post, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers).responseJSON(completionHandler: {
                response in
                
                self.balanceArray.removeAll()
                self.totalBTCAmount = 0
                
                let jsonResponse = response.result.value as! NSDictionary
                
                for item in jsonResponse {
                    
                    guard let numbers: [String:String] = item.value as? [String : String] else {return}
                    
                    guard let availableBalance: Double = Double(numbers["available"]!) else {return}
                    guard let onOrdersBalance: Double = Double(numbers["onOrders"]!) else {return}
                    guard let btcValue: Double = Double(numbers["btcValue"]!) else {return}
                    
                    guard let nameOfCoin: String = item.key as? String else {return}
                    
                    if availableBalance != 0.0 || onOrdersBalance != 0.0 {
                        self.balanceArray.append(Balance(coin: nameOfCoin, amount: availableBalance, btcValue: btcValue))
                        self.totalBTCAmount += Double(numbers["btcValue"]!)!
                    }
                    
                }
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
                
            })
            
        } else {
            
            print("can't show balances because the key and secret are nil")
            alert = UIAlertController(title: "Log in", message: "Please log in to access account information", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            //self.present(alert, animated: true, completion: nil)
            self.refreshControl.endRefreshing()
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
        
        if !balanceArray.isEmpty {
        
            cell.coinName.text = balanceArray[indexPath.row].coin
            
            if let amount = balanceArray[indexPath.row].amount {
                cell.amountLabel.text = String(amount)
            }
            
            if let btcValue = balanceArray[indexPath.row].btcValue {
                cell.btcValueLabel.text = String(btcValue)
            }
            
        } else {
            print("balance array is empty")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BalancesHeaderCell")
        
        let totalsLabel = UILabel(frame: CGRect(x: 8, y: 5, width: (cell?.bounds.width)!, height: 20))
        
        totalsLabel.font = UIFont(name: "Helvetica", size: 12)
        totalsLabel.text = "Total: \(totalBTCAmount) BTC"
        
        totalsLabel.textAlignment = .center
        
        cell?.addSubview(totalsLabel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        retrieveBalances()
    }
    
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(AccountTradesViewController.refresh), for: .allEvents)
        tableView.refreshControl = refreshControl
 
    }
    
    func refresh() {
        retrieveBalances()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        refreshControl.endRefreshing()
    }
}

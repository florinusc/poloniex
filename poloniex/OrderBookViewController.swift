//
//  OrderBookViewController.swift
//  poloniex
//
//  Created by Florin Uscatu on 8/24/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit
import Starscream

class OrderBookViewController: UITableViewController {

    var coinArr: [CoinPair] = []
    
    var coinPair = String()
    
    let orderBookQueue = DispatchQueue(label: "com.poloniex.orderBook", qos: .utility)
    
    var bids: [OrderBookEntry] = [] {
        didSet {
            orderBookQueue.async {
                self.bids.sort(by: {$0.price > $1.price})
            }
        }
    }
    
    var asks: [OrderBookEntry] = [] {
        didSet {
            orderBookQueue.async {
                self.asks.sort(by: {$0.price < $1.price})
            }
        }
    }
    
    var tempBids : NSDictionary = [:] {
        didSet {
            orderBookQueue.async {
                var tempTempBids: [OrderBookEntry] = []
                
                for order in self.tempBids {
                    
                    guard let price = order.key as? String else {return}
                    guard let amount = order.value as? String else {return}
                    
                    tempTempBids.append(OrderBookEntry(price: Double(price)!, amount: Double(amount)!))
                }
                
                self.bids = tempTempBids
            }
        }
    }
    
    var tempAsks : NSDictionary = [:] {
        didSet {
            orderBookQueue.async {
                var tempTempAsks: [OrderBookEntry] = []
                
                for order in self.tempAsks {
                    
                    guard let price = order.key as? String else {return}
                    guard let amount = order.value as? String else {return}
                    
                    tempTempAsks.append(OrderBookEntry(price: Double(price)!, amount: Double(amount)!))
                    
                }
                
                self.asks = tempTempAsks
            }

        }
    }
    
    var socket = WebSocket(url: URL(string: "wss://api2.poloniex.com")!)
    
    deinit {
        socket.disconnect(forceTimeout: 0)
        socket.delegate = nil
    }
    
    var reloadTimer: Timer!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if coinPair != "" {
            socket.connect()
            
            //set the timer to reload the table every 2 seconds
            reloadTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(OrderBookViewController.reloadTable), userInfo: nil, repeats: true)
            
        }
        
    }
    
    @objc func reloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        socket.delegate = self
        socket.connect()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        socket.disconnect()
        reloadTimer.invalidate()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderBookCell", for: indexPath) as! OrderBookCell
        
        if !bids.isEmpty && !asks.isEmpty {
            if indexPath.section == 0 {
                
                if asks.indices.contains(indexPath.row) {
                    cell.priceLabel.text = String(format: "%.8f", asks[indexPath.row].price)
                    cell.amountLabel.text = String(format: "%.8f", asks[indexPath.row].amount)
                    
                    cell.priceLabel.textColor = UIColor.red
                }

                return cell
                
            } else {
                
                if bids.indices.contains(indexPath.row) {
                    cell.priceLabel.text = String(format: "%.8f", bids[indexPath.row].price)
                    cell.amountLabel.text = String(format: "%.8f", bids[indexPath.row].amount)
                    
                    cell.priceLabel.textColor = UIColor.green
                }
                return cell
            }
        } else {
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
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}

extension OrderBookViewController : WebSocketDelegate {
    public func websocketDidConnect(socket: Starscream.WebSocket) {
        print("connected")
        let msg = "{\"command\":\"subscribe\",\"channel\":\"\(coinPair)\"}"
        socket.write(string: msg)
    }
    
    public func websocketDidDisconnect(socket: Starscream.WebSocket, error: NSError?) {
        print("disconnected")
    }
    
    public func websocketDidReceiveMessage(socket: Starscream.WebSocket, text: String) {
        
        DispatchQueue.global().async {
            guard let data = text.data(using: .utf16),
                let jsonData = try? JSONSerialization.jsonObject(with: data),
                let jsonDict = jsonData as? NSArray else {
                    return
            }
            
            let arrayCount = jsonDict.count as Int
            
            if arrayCount == 3 {
                
                if let entryDict = jsonDict[2] as? NSArray {
                    
                    for actualEntry in entryDict {
                        
                        if let entry = actualEntry as? NSArray {
                            
                            guard let marketChannel = entry[0] as? String else {return}
                            
                            switch marketChannel {
                            case "i":
                                self.asks.removeAll()
                                self.bids.removeAll()
                                
                                guard let previousEntries = entry[1] as? NSDictionary else {return}
                                guard let orderBook = previousEntries.value(forKey: "orderBook") as? NSArray else {return}
                                
                                guard let sellOrders = orderBook[0] as? NSDictionary else {return}
                                guard let buyOrders = orderBook[1] as? NSDictionary else {return}
                                
                                self.tempBids = buyOrders
                                self.tempAsks = sellOrders
                                
                            case "o":
                                
                                guard let entryType = entry[1] as? Int else {return}
                                guard let priceRef = entry[2] as? String else {return}
                                guard let newAmount = entry[3] as? String else {return}
                                
                                if entryType == 1 {
                                    
                                    let orderBookEntry = OrderBookEntry(price: Double(priceRef)!, amount: Double(newAmount)!)
                                    
                                    if let index = self.bids.index(where: {$0.price == orderBookEntry.price}) {
                                        
                                        if Double(newAmount) == 0.0 {
                                            if self.bids.indices.contains(index) {
                                                self.bids.remove(at: index)
                                            }
                                        } else {
                                            if self.bids.indices.contains(index) {
                                                self.bids[index].amount = Double(newAmount)!
                                            }
                                        }
                                        
                                    } else {
                                        self.bids.append(OrderBookEntry(price: Double(priceRef)!, amount: Double(newAmount)!))
                                        
                                        
                                    }
                                    
                                } else if entryType == 0 {
                                    let orderBookEntry = OrderBookEntry(price: Double(priceRef)!, amount: Double(newAmount)!)
                                    
                                    if let index = self.asks.index(where: {$0.price == orderBookEntry.price}) {
                                        
                                        if Double(newAmount) == 0.0 {
                                            if self.asks.indices.contains(index) {
                                                self.asks.remove(at: index)
                                            }
                                        } else {
                                            if self.asks.indices.contains(index) {
                                                self.asks[index].amount = Double(newAmount)!
                                            }
                                        }
                                        
                                    } else {
                                        self.asks.append(OrderBookEntry(price: Double(priceRef)!, amount: Double(newAmount)!))
                                        
                                        
                                    }
                                }
                            case "t":
                                guard let priceRef = entry[2] as? String else {return}
                                guard let newAmount = entry[3] as? String else {return}
                                self.bids.append(OrderBookEntry(price: Double(priceRef)!, amount: Double(newAmount)!))
                                self.bids.sort(by: {$0.price > $1.price})
                            default:
                                break
                            }
                            
                        }
                    }
                    
                } else {
                    print("could not cast to array")
                }
            }
            
        }
        
    }
    
    public func websocketDidReceiveData(socket: Starscream.WebSocket, data: Data) {
    }
}

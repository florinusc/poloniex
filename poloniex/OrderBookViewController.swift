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
    
    var bids: [OrderBookEntry] = [] {
        didSet {
            bids.sort(by: {$0.price > $1.price})
        }
    }
    var asks: [OrderBookEntry] = [] {
        didSet {
            asks.sort(by: {$0.price < $1.price})
        }
    }
    
    var tempBids : NSDictionary = [:] {
        didSet {
            for order in tempBids {
                
                guard let price = order.key as? String else {return}
                guard let amount = order.value as? String else {return}
                
                bids.append(OrderBookEntry(price: Double(price)!, amount: Double(amount)!))
            }
        }
    }
    var tempAsks : NSDictionary = [:] {
        didSet {
            for order in tempAsks {
                
                guard let price = order.key as? String else {return}
                guard let amount = order.value as? String else {return}
                
                asks.append(OrderBookEntry(price: Double(price)!, amount: Double(amount)!))
                
            }
        }
    }
    
    var socket = WebSocket(url: URL(string: "wss://api2.poloniex.com")!)
    
    deinit {
        socket.disconnect(forceTimeout: 0)
        socket.delegate = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        if coinPair != "" {
            socket.connect()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if let parentVC = self.parent as? TickerDetailMenuViewController {
            coinPair = parentVC.coinPair
        }
        
        socket.delegate = self
        socket.connect()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        socket.disconnect()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderBookCell", for: indexPath) as! OrderBookCell
            
            if !asks.isEmpty {
                cell.priceLabel.text = String(asks[indexPath.row].price)
                cell.amountLabel.text = String(format: "%.8f", asks[indexPath.row].amount)
                
                cell.priceLabel.textColor = UIColor.red
            }
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "orderBookCell", for: indexPath) as! OrderBookCell

            if !bids.isEmpty {
                cell.priceLabel.text = String(bids[indexPath.row].price)
                cell.amountLabel.text = String(format: "%.8f", bids[indexPath.row].amount)
                
                cell.priceLabel.textColor = UIColor.green
            }
            
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
        //print(text)
        
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
                            asks.removeAll()
                            bids.removeAll()
                            
                            guard let previousEntries = entry[1] as? NSDictionary else {return}
                            guard let orderBook = previousEntries.value(forKey: "orderBook") as? NSArray else {return}
                            
                            guard let sellOrders = orderBook[0] as? NSDictionary else {return}
                            guard let buyOrders = orderBook[1] as? NSDictionary else {return}
                            
                            tempBids = buyOrders
                            tempAsks = sellOrders
                            
                            print(bids)
                            
                        case "o":
                            
                            guard let entryType = entry[1] as? Int else {return}
                            guard let priceRef = entry[2] as? String else {return}
                            guard let newAmount = entry[3] as? String else {return}
                            
                            if entryType == 1 {
                                
                                print("bid, price: \(entry[2]), amount: \(entry[3])")
                                
                                let orderBookEntry = OrderBookEntry(price: Double(priceRef)!, amount: Double(newAmount)!)
                                
                                if let index = bids.index(where: {$0.price == orderBookEntry.price}) {
                                    print("found a match here: \(index)")
                                    
                                    if Double(newAmount) == 0.0 {
                                        print("deleted entry")
                                        bids.remove(at: index)
                                    } else {
                                        print("modified entry")
                                        bids[index].amount = Double(newAmount)!
                                    }
                                    
                                } else {
                                    print("cannot find this entry in the array")
                                    bids.append(OrderBookEntry(price: Double(priceRef)!, amount: Double(newAmount)!))
                                    
                                    
                                }
                                
                            } else if entryType == 0 {
                                print("ask, price: \(entry[2]), amount: \(entry[3])")
                                
                                let orderBookEntry = OrderBookEntry(price: Double(priceRef)!, amount: Double(newAmount)!)
                                
                                if let index = asks.index(where: {$0.price == orderBookEntry.price}) {
                                    print("found a match here: \(index)")
                                    
                                    if Double(newAmount) == 0.0 {
                                        print("deleted entry")
                                        asks.remove(at: index)
                                    } else {
                                        print("modified entry")
                                        asks[index].amount = Double(newAmount)!
                                    }
                                    
                                } else {
                                    print("cannot find this entry in the array")
                                    asks.append(OrderBookEntry(price: Double(priceRef)!, amount: Double(newAmount)!))
                                    
                                    
                                }
                            }
                        case "t":
                            guard let priceRef = entry[2] as? String else {return}
                            guard let newAmount = entry[3] as? String else {return}
                            print("cannot find this entry in the array")
                            bids.append(OrderBookEntry(price: Double(priceRef)!, amount: Double(newAmount)!))
                            bids.sort(by: {$0.price > $1.price})
                        default:
                            break
                        }
                        
                    }
                }
                
            } else {
                print("could not cast to array")
            }
        }
        
        tableView.reloadData()
    }
    
    public func websocketDidReceiveData(socket: Starscream.WebSocket, data: Data) {
        //print("received data is \(data)")
    }
}

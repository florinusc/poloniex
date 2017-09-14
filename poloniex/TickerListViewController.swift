//
//  TickerListViewController.swift
//  poloniex
//
//  Created by Florin Uscatu on 9/12/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit
import Starscream

class TickerListViewController: UITableViewController {
    
    var coinArr: [CoinPair] = []
    
    var socket = WebSocket(url: URL(string: "wss://api2.poloniex.com")!)
    
    deinit {
        socket.disconnect(forceTimeout: 0)
        socket.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        socket.delegate = self
        socket.connect()
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

}

extension TickerListViewController : WebSocketDelegate {
    public func websocketDidConnect(socket: Starscream.WebSocket) {
        print("connected")
        let msg = "{\"command\":\"subscribe\",\"channel\":1002}"
        socket.write(string: msg)
    }
    
    public func websocketDidDisconnect(socket: Starscream.WebSocket, error: NSError?) {
        print("disconnected")
    }
    
    public func websocketDidReceiveMessage(socket: Starscream.WebSocket, text: String) {
        //print(text)
        
        guard let data = text.data(using: .utf16),
            let jsonData = try? JSONSerialization.jsonObject(with: data),
            let jsonDict = jsonData as? NSArray,
            let arrayCount = jsonDict.count as? Int else {
            return
        }
        
        if arrayCount == 3 {
            if let coinArray = jsonDict[2] as? NSArray {
                if coinArray[0] as? Int == 174 {
                    print("lastPrice is: \(coinArray[1]), volume is: \(coinArray[5]), change is: \(coinArray[4])")
                }
            }
        }
        
    }
    
    public func websocketDidReceiveData(socket: Starscream.WebSocket, data: Data) {
        print("received data is \(data)")
    }
}

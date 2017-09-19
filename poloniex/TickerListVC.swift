
//
//  ViewController.swift
//  poloniex
//
//  Created by Florin Alexandru on 04/04/2017.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit
import Starscream

class TickerListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var coinData = NSDictionary()
    var coinPairs = [CoinPair]()
    var filteredTickers = [CoinPair]()
    var selectedCoinPair = String()
    
    let loadingView = UIView()
    
    let refreshControl = UIRefreshControl()
    
    var socket = WebSocket(url: URL(string: "wss://api2.poloniex.com")!)
    
    deinit {
        socket.disconnect(forceTimeout: 0)
        socket.delegate = nil
    }
    
    func createLoadingView() {
        
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        loadingView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        loadingView.layer.backgroundColor = UIColor(white: 0, alpha: 0.5).cgColor
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: view.layer.bounds.width/2 - 10, y: view.layer.bounds.height/2 - 30, width: 20, height: 20))
        loadingIndicator.startAnimating()
        loadingView.addSubview(loadingIndicator)
        
        let loadingLabel = UILabel(frame: CGRect(x: view.layer.bounds.width/2 - 40, y: view.layer.bounds.height/2, width: 80, height: 20))
        loadingLabel.text = "loading..."
        loadingLabel.textColor = UIColor.white
        loadingView.addSubview(loadingLabel)
        
        self.view.addSubview(loadingView)
        
    }
    
    func hideLoadingView() {
        DispatchQueue.main.async {
            self.loadingView.isHidden = true
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tickerSegue" {
            let destinationVC = segue.destination as! TickerDetail
            destinationVC.coinPair = selectedCoinPair
            destinationVC.coinData = coinData.value(forKey: selectedCoinPair) as! NSDictionary
            
            let chartsVC = storyboard?.instantiateViewController(withIdentifier: "ChartsViewController") as! ChartsViewController
            chartsVC.coinPair = selectedCoinPair
            chartsVC.coinData = coinData.value(forKey: selectedCoinPair) as! NSDictionary
        }
    }
    
    var mainCoin = "BTC"
    
    var tickerSortState = false
    var priceSortState = false
    var changeSortState = false
    var volumeSortState = false
    var nameSortState = false
    
    @IBAction func sortByTicker(_ sender: UIButton) {
        if !tickerSortState {
            coinPairs.sort {$0.secondCurrency < $1.secondCurrency}
            filteredTickers.sort {$0.secondCurrency < $1.secondCurrency}
            
            self.tableView.reloadData()
            
            tickerSortState = true
        } else {
            coinPairs.sort {$0.secondCurrency > $1.secondCurrency}
            filteredTickers.sort {$0.secondCurrency > $1.secondCurrency}
            
            self.tableView.reloadData()
            
            tickerSortState = false
        }
    }
    
    @IBAction func sortByPrice(_ sender: UIButton) {
        if !priceSortState {
            coinPairs.sort {$0.lastPrice < $1.lastPrice}
            filteredTickers.sort {$0.lastPrice < $1.lastPrice}
            
            self.tableView.reloadData()
            
            priceSortState = true
        } else {
            coinPairs.sort {$0.lastPrice > $1.lastPrice}
            filteredTickers.sort {$0.lastPrice > $1.lastPrice}
            
            self.tableView.reloadData()
            
            priceSortState = false
        }
    }
    
    @IBAction func sortByVolume(_ sender: UIButton) {
        if !volumeSortState {
            coinPairs.sort {$0.volume < $1.volume}
            filteredTickers.sort {$0.volume < $1.volume}
            
            self.tableView.reloadData()
            
            volumeSortState = true
        } else {
            coinPairs.sort {$0.volume > $1.volume}
            filteredTickers.sort {$0.volume > $1.volume}
            
            self.tableView.reloadData()
            
            volumeSortState = false
        }
    }
    
    @IBAction func sortByChange(_ sender: UIButton) {
        if !changeSortState {
            coinPairs.sort {$0.change < $1.change}
            filteredTickers.sort {$0.change < $1.change}
            
            self.tableView.reloadData()
            
            changeSortState = true
        } else {
            coinPairs.sort {$0.change > $1.change}
            filteredTickers.sort {$0.change > $1.change}
            
            self.tableView.reloadData()
            
            changeSortState = false
        }
    }
    
    @IBAction func sortByName(_ sender: UIButton) {
        if !nameSortState {
            coinPairs.sort {$0.name < $1.name}
            filteredTickers.sort {$0.name < $1.name}
            
            self.tableView.reloadData()
            
            nameSortState = true
        } else {
            coinPairs.sort {$0.name > $1.name}
            filteredTickers.sort {$0.name > $1.name}
            
            self.tableView.reloadData()
            
            nameSortState = false
        }
    }
    
    @IBOutlet weak var segmentedControlOutlet: UISegmentedControl!
    
    
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            mainCoin = "BTC"
        case 1:
            mainCoin = "ETH"
        case 2:
            mainCoin = "XMR"
        case 3:
            mainCoin = "USDT"
        default:
            break
        }
        
        requestData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        socket.delegate = self
        
        createLoadingView()
        
        requestData()
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(AccountTradesViewController.refresh), for: .allEvents)
        tableView.refreshControl = refreshControl
    }
    
    func refresh() {
        requestData()
    }
    
    func requestData() {
        let url = URL(string: "https://poloniex.com/public?command=returnTicker")
        let request: NSMutableURLRequest = NSMutableURLRequest()
        request.url = url
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        
        session.dataTask(with: url!, completionHandler: {
            (data, response, error) -> Void in
            if error == nil {
                DispatchQueue.main.async {
                    do {
                        
                        if let jsonData = data {
                            
                            self.coinPairs.removeAll()
                            self.socket.disconnect()
                            
                            let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! NSDictionary
                            
                            self.coinData = json
                            
                            for item in json {
                                let pair = item.key as! String
                                
                                let pairData = item.value as! NSDictionary
                                
                                var volume = Double(0.0)
                                var change = Double(0.0)
                                var lastPrice = Double(0.0)
                                
                                if let tempvolume = pairData.value(forKey: "baseVolume") as? String {
                                    if let temptempvolume = Double(tempvolume) {
                                        volume = round(temptempvolume * 1000) / 1000
                                    }
                                }
                                
                                if let tempchange = pairData.value(forKey: "percentChange") as? String {
                                    if let temptempchange = Double(tempchange) {
                                        change = round(temptempchange * 10000) / 100
                                    }
                                }
                                
                                if let templastPrice = pairData.value(forKey: "last") as? String {
                                    if let temptemplastPrice = Double(templastPrice) {
                                        lastPrice = temptemplastPrice
                                    }
                                }
                                
                                let pairArr = pair.characters.split(separator: "_").map(String.init)
                                
                                if !self.coinPairs.contains(where: {$0.pair == pair}) {
                                    
                                    if self.mainCoin == pairArr[0] {
                                        
                                    
                                        self.coinPairs.append(CoinPair(id: 0, pair: pair, firstCurrency: pairArr[0], secondCurrency: pairArr[1], name: "", volume: volume, change: change, lastPrice: lastPrice))
 
                                    }
                                }
                            }
                            self.requestCoinName()
                        }
                    } catch let err {
                        print(err)
                    }
                }
            }
        }).resume()
    }

    func requestCoinName() {
        
        for (index, coin) in coinPairs.enumerated() {
            
            if let path = Bundle.main.path(forResource: "coinnames", ofType: "json") {
                do {
                    let jsonData = try NSData(contentsOfFile: path, options: .mappedIfSafe)
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: jsonData as Data, options: .mutableContainers) as! NSDictionary
                        
                        let ticker = coin.secondCurrency
                        
                        if let coinName = jsonResult.value(forKey: ticker) {
                            self.coinPairs[index].name = coinName as! String
                        } else {
                            print("there is no name for \(ticker)")
                        }

                    } catch {}
                } catch {}
            } else {
                print("we have a problem")
            }
        }
        requestCoinID()
    }
    
    func requestCoinID() {
        for (index, coin) in coinPairs.enumerated() {
            if let path = Bundle.main.path(forResource: "coinIDs", ofType: "json") {
                do {
                    let jsonData = try NSData(contentsOfFile: path, options: .mappedIfSafe)
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: jsonData as Data, options: .mutableContainers) as! NSDictionary
                        
                        let pair = coin.pair
                        
                        print(pair)
                        
                        if let coinDetail = jsonResult.value(forKey: pair) as? NSDictionary {
                            if let id = coinDetail.value(forKey: "id") as? Int {
                                self.coinPairs[index].id = id
                                
                                print("coin pair \(self.coinPairs[index].pair) has following id: \(id)")
                            } else {
                                print("id could not be attributed")
                            }
                        } else {
                            print("problem with finding coin pair")
                        }
                    }
                } catch let err { print(err) }
            }
        }
        self.tableView.reloadData()
        self.hideLoadingView()
        refreshControl.endRefreshing()
        socket.connect()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinPairs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TickerCell
        
            cell.tickerLabel.text = coinPairs[indexPath.row].secondCurrency
            cell.detailLabel.text = coinPairs[indexPath.row].name
            cell.lastPriceLabel.text = String(coinPairs[indexPath.row].lastPrice)
            cell.volumeLabel.text = String(coinPairs[indexPath.row].volume)
            cell.changeLabel.text = String(coinPairs[indexPath.row].change) + "%"
            
            if coinPairs[indexPath.row].change < 0.0 {
                cell.changeLabel.textColor = UIColor.red
            } else {
                cell.changeLabel.textColor = UIColor.init(red: 0, green: 204, blue: 0, alpha: 1)
            }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedCoinPair = coinPairs[indexPath.row].pair
        
        performSegue(withIdentifier: "tickerSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let viewToReturn = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderCell
        
        viewToReturn.addSubview(headerCell)
        
        return viewToReturn
    }
    
}

extension TickerListVC : WebSocketDelegate {
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
            let jsonDict = jsonData as? NSArray else {
                return
        }
        
        let arrayCount = jsonDict.count
        
        if arrayCount == 3 {
            if let coinArray = jsonDict[2] as? NSArray {
                
                
                for (index, coin) in coinPairs.enumerated() {
                    if coinArray[0] as? Int == coin.id {
                        
                        if let templastPrice = coinArray[1] as? String {
                            if let temptemplastPrice = Double(templastPrice) {
                                coinPairs[index].lastPrice = temptemplastPrice
                            }
                        }
                        
                        if let tempVolume = coinArray[5] as? String {
                            if let temptempVolume = Double(tempVolume) {
                                coinPairs[index].volume = round(temptempVolume * 1000) / 1000
                            }
                        }
                        
                        if let tempChange = coinArray[4] as? String {
                            if let temptempChange = Double(tempChange) {
                                coinPairs[index].change = round(temptempChange * 10000) / 100
                            }
                        }
                        
                        let indexPath = NSIndexPath(row: index, section: 0)
                        tableView.reloadRows(at: [indexPath as IndexPath], with: .none)
                        
                    }
                }
                
            } else {
                print("coinArray cannot be an array")
            }
        } else {
            print("array is missing an item")
        }
        
    }
    
    public func websocketDidReceiveData(socket: Starscream.WebSocket, data: Data) {
        print("received data is \(data)")
    }
}



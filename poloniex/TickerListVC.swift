
//
//  ViewController.swift
//  poloniex
//
//  Created by Florin Alexandru on 04/04/2017.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit

class TickerListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var tableView: UITableView!
    
    var coinData = NSDictionary()
    var coinPairs = [CoinPair]()
    var filteredTickers = [CoinPair]()
    var selectedCoinPair = String()
    
    let loadingView = UIView()
    
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
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        createLoadingView()
        
        requestData()
        
        //search
//        searchController.searchResultsUpdater = self
//        searchController.dimsBackgroundDuringPresentation = false
//        definesPresentationContext = true
//        tableView.tableHeaderView = searchController.searchBar
    
//        let poloColor = UIColor.gray
//        searchController.searchBar.tintColor = poloColor
//        searchController.searchBar.barTintColor = UIColor.white
//        searchController.searchBar.delegate = self
        
    }
    
    func requestData() {
        let url = URL(string: "https://poloniex.com/public?command=returnTicker")
        let request: NSMutableURLRequest = NSMutableURLRequest()
        request.url = url
        request.httpMethod = "GET"
        
        self.coinPairs.removeAll()
        
        let session = URLSession.shared
        
        session.dataTask(with: url!, completionHandler: {
            (data, response, error) -> Void in
            if error == nil {
                DispatchQueue.main.async {
                    do {
                        
                        if let jsonData = data {
                            
                            print(jsonData)
                            
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
                                        
                                    
                                    self.coinPairs.append(CoinPair(pair: pair, firstCurrency: pairArr[0], secondCurrency: pairArr[1], name: "", volume: volume, change: change, lastPrice: lastPrice))
                                        
                                    
                                        
                                    }
                                }
                            }
                            self.requestCoinInfo()
                        }
                    } catch let err {
                        print(err)
                    }
                }
            }
        }).resume()
    }

    func requestCoinInfo() {
        
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
                        self.hideLoadingView()
                    } catch {}
                } catch {}
            } else {
                print("we have a problem")
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
//        if searchController.isActive && searchController.searchBar.text != "" {
//            print("number of rows is: \(filteredTickers.count)")
//            return filteredTickers.count
//        }
        
        return coinPairs.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TickerCell
        
//        if searchController.isActive && searchController.searchBar.text != "" {
//            
//            cell.tickerLabel.text = filteredTickers[indexPath.row].secondCurrency
//            cell.detailLabel.text = filteredTickers[indexPath.row].name
//            cell.lastPriceLabel.text = String(filteredTickers[indexPath.row].lastPrice)
//            cell.volumeLabel.text = String(filteredTickers[indexPath.row].volume)
//            cell.changeLabel.text = String(filteredTickers[indexPath.row].change) + "%"
//            
//            if filteredTickers[indexPath.row].change < 0.0 {
//                cell.changeLabel.textColor = UIColor.red
//            } else {
//                cell.changeLabel.textColor = UIColor.init(red: 0, green: 204, blue: 0, alpha: 1)
//            }
//            
//        } else {
        
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
            
        //}
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        if searchController.isActive && searchController.searchBar.text != "" {
//            selectedCoinPair = filteredTickers[indexPath.row].pair
//        } else {
            selectedCoinPair = coinPairs[indexPath.row].pair
        //}
        performSegue(withIdentifier: "tickerSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    
//    func filterContentForSearchText(searchText: String) {
//        filteredTickers = coinPairs.filter { ticker in
//            return (ticker.secondCurrency.lowercased().contains(searchText.lowercased()) || ticker.name.lowercased().contains(searchText.lowercased()))
//        }
//        for i in filteredTickers {
//            
//            print(i.pair)
//        }
//        tableView.reloadData()
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "headerCell") as! HeaderCell
        
        return headerCell
    }
    
}

//extension TickerListVC: UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//        filterContentForSearchText(searchText: searchController.searchBar.text!)
//    }
//}
//
//extension TickerListVC: UISearchBarDelegate {
//    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
//        filterContentForSearchText(searchText: searchBar.text!)
//    }
//}


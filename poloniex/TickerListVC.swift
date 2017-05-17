
//
//  ViewController.swift
//  poloniex
//
//  Created by Florin Alexandru on 04/04/2017.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit

class TickerListVC: UITableViewController {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var coinData = NSDictionary()
    var coinPairs = [CoinPair]()
    var filteredTickers = [CoinPair]()
    var selectedCoinPair = String()
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tickerSegue" {
            let destinationVC = segue.destination as! TickerDetail
            destinationVC.coinPair = selectedCoinPair
            destinationVC.coinData = coinData.value(forKey: selectedCoinPair) as! NSDictionary
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Poloniex"
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        requestData()
        
        //requestCoinInfo()
        
        //search
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.scopeButtonTitles = ["All", "BTC", "ETH", "XMR", "USDT"]
        searchController.searchBar.tintColor = UIColor.black
        searchController.searchBar.delegate = self
        
    }
    
    func requestData() {
        let url = URL(string: "https://poloniex.com/public?command=returnTicker")
        let request: NSMutableURLRequest = NSMutableURLRequest()
        request.url = url
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        
        session.dataTask(with: url!, completionHandler: {
            (data, response, error) -> Void in
            
            do {
                if let jsonData = data {
                    print(jsonData)
                    
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! NSDictionary
                    
                    self.coinData = json
                    
                    for item in json {
                        let pair = item.key as! String
                        
                        let pairArr = pair.characters.split(separator: "_").map(String.init)
                        
                        if !self.coinPairs.contains(where: {$0.pair == pair}) {
                            self.coinPairs.append(CoinPair(pair: pair, firstCurrency: pairArr[0], secondCurrency: pairArr[1], name: "", imageURL: "", image: UIImage()))
                        }
                    }
                    self.requestCoinInfo()
                    self.tableView.reloadData()
                }
            } catch let err {
                print(err)
            }
        }).resume()
    }
    
    func requestCoinInfo() {
        let url = URL(string: "https://www.cryptocompare.com/api/data/coinlist/")
        let request: NSMutableURLRequest = NSMutableURLRequest()
        request.url = url
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        
        session.dataTask(with: url!, completionHandler: {
            (data, response, error) -> Void in
            
            do {
                
                if let jsonData = data {
                    let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! [String: Any]
                    
                    let coins = json["Data"]! as? [String:[String:Any]]
                    
                    for (i, coinner) in self.coinPairs.enumerated() {
                        if let coin = coins?[coinner.secondCurrency] {
                            if let name = coin["CoinName"] {
                                self.coinPairs[i].name = name as! String
                                print(name)
                            }
                            if let url = coin["ImageUrl"] {
                                self.coinPairs[i].imageURL = url as! String
                                self.coinPairs[i].image = self.requestCoinLogo(coinURL: ("https://www.cryptocompare.com" + (url as! String)))
                            }
                        }
                    }
                }
            } catch let err {
                print(err)
            }
        
        }).resume()
        
        self.tableView.reloadData()
        
    }
    
    func requestCoinLogo(coinURL: String) -> UIImage {
        
        var coinLogo = UIImage()
        
        let coinLogoURL = URL(string: coinURL)
        let session = URLSession(configuration: .default)
        
        let dlLogoTask = session.dataTask(with: coinLogoURL!) { (data, response, error) in
            if let e = error {
                print(e)
            } else {
                if (response as? HTTPURLResponse) != nil {
                    if let imageData = data {
                        let image = UIImage(data: imageData)
                        coinLogo = image!
                    } else {
                        print("couldn't get image")
                    }
                } else {
                    print("couldn't get response")
                }
            }
        }
        
        dlLogoTask.resume()
        return coinLogo
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredTickers.count
        }
        
        return coinPairs.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TickerCell
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            cell.coinImage.image = filteredTickers[indexPath.row].image
            cell.tickerLabel.text = filteredTickers[indexPath.row].pair
            cell.detailLabel.text = filteredTickers[indexPath.row].name
            
        } else {
            
            cell.coinImage.image = coinPairs[indexPath.row].image
            cell.tickerLabel.text = coinPairs[indexPath.row].pair
            cell.detailLabel.text = coinPairs[indexPath.row].name
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            selectedCoinPair = filteredTickers[indexPath.row].pair
        } else {
            selectedCoinPair = coinPairs[indexPath.row].pair
        }
        performSegue(withIdentifier: "tickerSegue", sender: self)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredTickers = coinPairs.filter { ticker in
            let categoryMatch = (scope == "All") || (ticker.firstCurrency == scope || ticker.name == scope)
            return categoryMatch && (ticker.secondCurrency.lowercased().contains(searchText.lowercased()) || ticker.name.lowercased().contains(searchText.lowercased()))
        }
        tableView.reloadData()
    }
    
}

extension TickerListVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
    }
}

extension TickerListVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchText: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}


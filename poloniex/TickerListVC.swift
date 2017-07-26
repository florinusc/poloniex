
//
//  ViewController.swift
//  poloniex
//
//  Created by Florin Alexandru on 04/04/2017.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit

class TickerListVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let searchController = UISearchController(searchResultsController: nil)
    
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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let logInBttn = UIBarButtonItem(title: "Log In", style: .plain, target: self, action: nil)
        
        self.navigationItem.leftBarButtonItem = logInBttn
        
        let logoImage = UIImage(named: "poloniex")
        self.navigationItem.titleView = UIImageView(image: logoImage)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        createLoadingView()
        
        requestData()
        
        //search
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.scopeButtonTitles = ["All", "BTC", "ETH", "XMR", "USDT"]
        let poloColor = UIColor.gray
        searchController.searchBar.tintColor = poloColor
        searchController.searchBar.barTintColor = UIColor.white
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
            if error == nil {
                DispatchQueue.main.async {
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
                        }
                    } catch let err {
                        print(err)
                    }
                }
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
            if error == nil {
                DispatchQueue.main.async {
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
                                        self.requestCoinLogo(coinURL: ("https://www.cryptocompare.com" + (url as! String)), index: i)
                                    }
                                }
                            }
                        }
                    } catch let err {
                        print(err)
                    }
                }
            }
        }).resume()
    }
    
    func requestCoinLogo(coinURL: String, index: Int) {
        
        let coinLogoURL = URL(string: coinURL)
        let session = URLSession(configuration: .default)
        
        let dlLogoTask = session.dataTask(with: coinLogoURL!) { (data, response, error) in
            if let e = error {
                print(e)
            } else {
                DispatchQueue.main.async {
                    if (response as? HTTPURLResponse) != nil {
                        if let imageData = data {
                            //let image = UIImage(data: imageData)
                            if let image = UIImage(data: imageData) {
                                self.coinPairs[index].image = image
                            }
                        } else {
                            print("couldn't get image")
                        }
                    } else {
                        print("couldn't get response")
                    }
                }
            }
            self.hideLoadingView()
        }
        
        dlLogoTask.resume()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            print("number of rows is: \(filteredTickers.count)")
            return filteredTickers.count
        }
        
        return coinPairs.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TickerCell
        
        if searchController.isActive && searchController.searchBar.text != "" {
            
            print("cell for row got called")
            
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            selectedCoinPair = filteredTickers[indexPath.row].pair
        } else {
            selectedCoinPair = coinPairs[indexPath.row].pair
        }
        performSegue(withIdentifier: "tickerSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        var heightToReturn = 0
        
        if searchController.isActive {
            heightToReturn = 44
        }
        
        return CGFloat(heightToReturn)
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredTickers = coinPairs.filter { ticker in
            let categoryMatch = (scope == "All") || (ticker.firstCurrency == scope || ticker.name == scope || ticker.secondCurrency == scope)
            return categoryMatch && (ticker.secondCurrency.lowercased().contains(searchText.lowercased()) || ticker.name.lowercased().contains(searchText.lowercased()))
        }
        print("new search")
        for i in filteredTickers {
            
            print(i.pair)
        }
        print("finished searching")
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


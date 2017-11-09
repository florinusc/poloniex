//
//  ChartsViewController.swift
//  poloniex
//
//  Created by Florin Uscatu on 8/24/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit

class ChartsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var chartPeriod = 300
    var coinData = NSDictionary()
    var coinPair = String()
    var chartDataArray: Array<ChartData> = []
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func periodSegmentControlAction(_ sender: UISegmentedControl) {
    
        let segValue = sender.selectedSegmentIndex
        
        switch segValue {
        case 0:
            chartPeriod = 300
        case 1:
            chartPeriod = 1800
        case 2:
            chartPeriod = 14400
        case 3:
            chartPeriod = 86400
        default:
            break
        }
        
        loadAPI()
        tableView.reloadData()
    
    }
    
    func takeApartCoinPair() -> String {
        
        var coinPairArr = coinPair.components(separatedBy: "_")
        let firstCoin:String = coinPairArr[0]
        
        return firstCoin
    }
    
    func loadAPI() {
        let date = NSDate()
        
        let currentTime = Int64(floor(date.timeIntervalSince1970))
        var previousTime = Int64()
        
        if let previousDate = Calendar.current.date(byAdding: .second, value: -chartPeriod*20, to: date as Date) {
            previousTime = Int64(floor(previousDate.timeIntervalSince1970))
        }
        
        let url = URL(string: "https://poloniex.com/public?command=returnChartData&currencyPair=\(coinPair)&start=\(previousTime)&end=\(currentTime)&period=\(chartPeriod)")
        
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
                            let json = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers) as! [NSDictionary]
                            
                            self.chartDataArray.removeAll()
                            
                            for item in json {
                                let close: Double = item.value(forKey: "close") as! Double
                                let open: Double = item.value(forKey: "open") as! Double
                                let volume: Double = item.value(forKey: "volume") as! Double
                                let high: Double = item.value(forKey: "high") as! Double
                                let low: Double = item.value(forKey: "low") as! Double
                                let date: Int = item.value(forKey: "date") as! Int
                                let quoteVolume: Double = item.value(forKey: "quoteVolume") as! Double
                                let weightedAverage: Double = item.value(forKeyPath: "weightedAverage") as! Double
                                
                                self.chartDataArray.append(ChartData(date: date, high: high, low: low, open: open, close: close, volume: volume, quoteVolume: quoteVolume, weightedAverage: weightedAverage))
                                
                            }
                            
                            self.tableView.reloadData()
                        }
                        
                        
                    } catch let err {
                        print(err)
                    }
                }
            }
            
        }).resume()
        
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let parentVC = self.parent as? TickerDetailMenuViewController {
            coinData = parentVC.coinData
            coinPair = parentVC.coinPair
            chartDataArray = parentVC.chartDataArray
            
            loadAPI()
            tableView.reloadData()
        }
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch indexPath.row {
        case 0:
            let priceLineCell = tableView.dequeueReusableCell(withIdentifier: "priceLineCell", for: indexPath) as! PriceLineCell
            priceLineCell.currentPriceLabel.text = coinData.value(forKey: "last") as? String
            priceLineCell.highestPriceLabel.text = coinData.value(forKey: "high24hr") as? String
            priceLineCell.lowestPriceLabel.text = coinData.value(forKey: "low24hr") as? String
            priceLineCell.firstVolumeLabel.text = coinData.value(forKey: "baseVolume") as? String
            priceLineCell.secondVolumeLabel.text = coinData.value(forKey: "quoteVolume") as? String
            priceLineCell.priceChangeLabel.text = coinData.value(forKey: "percentChange") as? String
            
            var priceLine = PriceLineView()
            
            priceLine = PriceLineView(frame: CGRect(x: 2.5, y: 21, width: priceLineCell.bounds.width - 5, height: 20))
            
            priceLine.currentPrice = Double(coinData.value(forKey: "last") as! String)!
            priceLine.highestPrice = Double(coinData.value(forKey: "high24hr") as! String)!
            priceLine.lowestPrice = Double(coinData.value(forKey: "low24hr") as! String)!
            
            priceLineCell.addSubview(priceLine)
            
            return priceLineCell
        case 1:
            let chartCell = tableView.dequeueReusableCell(withIdentifier: "chartCell", for: indexPath) as! ChartCell
            
            for view in chartCell.subviews {
                view.removeFromSuperview()
            }
            
            var graph = GraphView()
            graph = GraphView(frame: CGRect(x: 2.5, y: 2.5, width: (chartCell.bounds.width - 5), height: (chartCell.bounds.height - 5)))
            graph.chartPeriod = chartPeriod
            graph.denomination = takeApartCoinPair()
            graph.graphData = chartDataArray
            
            chartCell.addSubview(graph)
            
            return chartCell
        default:
            let periodChartcell = tableView.dequeueReusableCell(withIdentifier: "periodChartCell", for: indexPath) as! PeriodChartCell
            return periodChartcell

        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var heightToReturn = CGFloat()
        
        if indexPath.row == 0 {
            heightToReturn = 100
        } else if indexPath.row == 1 {
            heightToReturn = 300
        } else {
            heightToReturn = 44
        }
        
        return heightToReturn
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
}

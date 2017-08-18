//
//  TickerDetail.swift
//  poloniex
//
//  Created by Florin Alexandru on 05/04/2017.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit

class TickerDetail: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var chartPeriod = 300
    var coinData = NSDictionary()
    var coinPair = String()
    
    var graphPoints: Array<Double> = []
    
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
        
        print("segment control works: \(chartPeriod)")
        
        loadAPI()
        tableView.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        loadAPI()
        tableView.reloadData()
    }
    
    func takeApartCoinPair() -> String {
        
        var coinPairArr = coinPair.components(separatedBy: "_")
        
        let firstCoin:String = coinPairArr[0]
        let secondCoin:String = coinPairArr[1]
        
        print("I split the coin pair!")
        
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
                            
                            print("json data is: \(json)")
                            
                            self.graphPoints.removeAll()
                            
                            for item in json {
                                let lastPrice = item.value(forKey: "close")
                                
                                print("last price is \(lastPrice as! Double)")
                                
                                self.graphPoints.append(lastPrice as! Double)
                                
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = coinPair
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinData.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        switch indexPath.row {
        case 0:
            let chartCell = tableView.dequeueReusableCell(withIdentifier: "chartCell", for: indexPath) as! ChartCell
            
            for view in chartCell.subviews {
                view.removeFromSuperview()
            }
            
            var graph = GraphView()
            graph = GraphView(frame: CGRect(x: 2.5, y: 2.5, width: (chartCell.bounds.width - 5), height: (chartCell.bounds.height - 5)))
            graph.graphPoints = graphPoints
            graph.denomination = takeApartCoinPair()
            chartCell.addSubview(graph)
            
            return chartCell
        case 1:
            let periodChartcell = tableView.dequeueReusableCell(withIdentifier: "periodChartCell", for: indexPath) as! PeriodChartCell
            return periodChartcell
        default:
            var cell = UITableViewCell()
            cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
            cell.textLabel?.text = coinData.allKeys[indexPath.row - 2] as? String
            cell.detailTextLabel?.text = coinData.allValues[indexPath.row - 2] as? String
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        }
        
        return 44
    }

}

//
//  TickerDetailMenuViewController.swift
//  poloniex
//
//  Created by Florin Uscatu on 9/8/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit
import Parchment

@IBDesignable class TickerDetailMenuViewController: UIViewController {

    @IBInspectable var menuBackgroundColor:UIColor = UIColor.gray
    
    var coinData = NSDictionary()
    var coinPair = String()
    var chartDataArray: Array<ChartData> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Array to keep track of controllers in page menu
        var controllerArray : [UIViewController] = []
        
        let chartsViewController : ChartsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChartsViewController") as! ChartsViewController
        chartsViewController.title = "Charts"
        chartsViewController.coinPair = coinPair
        chartsViewController.coinData = coinData
        chartsViewController.chartDataArray = chartDataArray
        controllerArray.append(chartsViewController)
        
        let orderBookViewController : OrderBookViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OrderBookViewController") as!OrderBookViewController
        orderBookViewController.title = "Order Book"
        orderBookViewController.coinPair = coinPair
        controllerArray.append(orderBookViewController)
        
        let tradingViewController : TradingViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TradingVC") as! TradingViewController
        tradingViewController.title = "New Trade"
        tradingViewController.coinPair = coinPair
        controllerArray.append(tradingViewController)
        
        let ordersViewController : TickerOrdersViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TickerOrders") as! TickerOrdersViewController
        ordersViewController.title = "Orders"
        ordersViewController.coinPair = coinPair
        controllerArray.append(ordersViewController)
        
        let tickerTradesViewController : TickerTrades = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TickerTrades") as! TickerTrades
        tickerTradesViewController.title = "Trades"
        tickerTradesViewController.coinPair = coinPair
        controllerArray.append(tickerTradesViewController)
        
        let pagingViewController = CustomPagingController(viewControllers: controllerArray, options: PageMenuOptions())
        
        // Make sure you add the PagingViewController as a child view
        // controller and contrain it to the edges of the view.
        addChildViewController(pagingViewController)
        view.addSubview(pagingViewController.view)
        view.constrainToEdges(pagingViewController.view)
        pagingViewController.didMove(toParentViewController: self)
        
    }

}

class CustomPagingController: FixedPagingViewController {
    var coinData = NSDictionary()
    var coinPair = String()
    var chartDataArray: Array<ChartData> = []
}

// The options used for both paging view controllers
struct PageMenuTheme: PagingTheme {
    let indicatorColor: UIColor = UIColor.white
    let selectedTextColor: UIColor = UIColor.white
    let textColor: UIColor = UIColor.lightText
    let backgroundColor: UIColor = UIColor(red: 47/255, green: 70/255, blue: 73/255, alpha: 1)
    let headerBackgroundColor: UIColor = UIColor(red: 47/255, green: 70/255, blue: 73/255, alpha: 1)
}

struct PageMenuOptions: PagingOptions {
    let theme: PagingTheme = PageMenuTheme()
}

extension UIView {
    
    func constrainToEdges(_ subview: UIView) {
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        var topConstraint = NSLayoutConstraint()
        
        topConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1.0,
            constant: 0)
        
        let bottomConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0)
        
        let leadingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0)
        
        let trailingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0)
        
        addConstraints([
            topConstraint,
            bottomConstraint,
            leadingContraint,
            trailingContraint])
    }
    
}


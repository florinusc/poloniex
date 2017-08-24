//
//  PageViewController.swift
//  poloniex
//
//  Created by Florin Uscatu on 8/24/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {

    var coinData = NSDictionary()
    var coinPair = String()
    var chartDataArray: Array<ChartData> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("coin pair is \(coinPair) from page")
        
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction:.forward, animated: true, completion: nil)
        }
    
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController(name: "ChartsViewController")]
    }()
    
    private func newViewController(name: String) ->UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:name)
    }
}


extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
}

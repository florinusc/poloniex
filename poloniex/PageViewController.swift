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
    
    var selectedPage = 0 {
        didSet {
            loadSelectedPage(funcSelectedPage: selectedPage)
            
            print("selected page is \(selectedPage)")
        }
    }
    
    var currentPage = 0
    
    required init(coder aDecoder:NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("coin pair is \(coinPair) from page")
        
        dataSource = self
        
        loadSelectedPage(funcSelectedPage: selectedPage)
    
    }
    
    func loadSelectedPage(funcSelectedPage: Int) {
        let newViewController = orderedViewControllers[funcSelectedPage]
        if funcSelectedPage > currentPage {
            setViewControllers([newViewController], direction:.forward, animated: true, completion: nil)
            currentPage += 1
        } else if funcSelectedPage < currentPage {
            setViewControllers([newViewController], direction:.reverse, animated: true, completion: nil)
            currentPage -= 1
        } else {
            print("staying on the same page")
            setViewControllers([newViewController], direction:.forward, animated: false, completion: nil)
        }
        
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController(name: "ChartsViewController"), self.newViewController(name: "OrderBookViewController")]
    }()
    
    private func newViewController(name: String) ->UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:name)
    }
}


extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllersIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllersIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
}

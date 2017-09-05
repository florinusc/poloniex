//
//  LoginPageViewController.swift
//  poloniex
//
//  Created by Florin Uscatu on 8/28/17.
//  Copyright © 2017 AppRocket. All rights reserved.
//

import UIKit

class LoginPageViewController: UIPageViewController, UIPageViewControllerDelegate {

    var pageControl = UIPageControl()
    
    func configurePageControl() {
        // The total number of pages that are available is based on how many available colors we have.
        pageControl = UIPageControl(frame: CGRect(x: 0,y: UIScreen.main.bounds.maxY - 150,width: UIScreen.main.bounds.width,height: 50))
        self.pageControl.numberOfPages = orderedViewControllers.count
        self.pageControl.currentPage = 0
        self.pageControl.tintColor = UIColor(red: 5, green: 31, blue: 33, alpha: 1)
        self.pageControl.pageIndicatorTintColor = UIColor.white
        self.pageControl.currentPageIndicatorTintColor = UIColor.black
        self.view.addSubview(pageControl)
        
        print("page control has been added")
    }
    
    required init(coder aDecoder:NSCoder) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Log in"
        
        
        
        dataSource = self
        self.delegate = self
        configurePageControl()
        
        setViewControllers([orderedViewControllers[0]], direction: .forward, animated: true, completion: nil)
        
        print("the number of vcs is:\(orderedViewControllers.count)")
        
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController(name: "Step1ViewController"), self.newViewController(name: "Step2ViewController"), self.newViewController(name: "Step3ViewController")]
    }()
    
    private func newViewController(name: String) ->UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier:name)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        
        //print("current vc is \(orderedViewControllers.index(of: pageContentViewController))")
        
        self.pageControl.currentPage = orderedViewControllers.index(of: pageContentViewController)!
    }

}

extension LoginPageViewController: UIPageViewControllerDataSource {
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

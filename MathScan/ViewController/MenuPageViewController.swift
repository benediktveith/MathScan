//
//  MenuPageViewController.swift
//  MathScan
//
//  Created by Benedikt Veith on 02.11.17.
//  Copyright © 2017 benedikt-veith. All rights reserved.
//

import Foundation
import UIKit

protocol MenuPageViewControllerDelegate: class {
    func updateHeaderAndView(index: Int, progress: CGFloat);
    func updateScrollHeader(currentIndex: Int, index: Int, progress: CGFloat);
    
    func transitionDone(index: Int);
}

class MenuPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIScrollViewDelegate, UIPageViewControllerDelegate {
    weak var customDelegate: MenuPageViewControllerDelegate!
    
    var goingToIndex = 0;
    var currentIndex = 1;
    var transitionDone = false;
    var blockScrollViewDelegate = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let firstViewController = orderedViewControllers[1];
        
        self.setViewControllers([firstViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil);
        
        self.dataSource = self;
        self.delegate = self;
        
        for subView in view.subviews {
            if let scrollView = subView as? UIScrollView {
                scrollView.delegate = self;
            }
        }
        
        self.view.backgroundColor = UIColor.clear;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
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
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let viewControllerIndex = orderedViewControllers.index(of: pendingViewControllers[0]);
        
        self.goingToIndex = viewControllerIndex!;
        self.transitionDone = false;
        self.blockScrollViewDelegate = false;
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        self.transitionDone = true;
        
        if completed {
            let viewControllerIndex = orderedViewControllers.index(of: (pageViewController.viewControllers?.first)!);
            currentIndex = viewControllerIndex!;
            
            customDelegate.transitionDone(index: self.goingToIndex);
        }
    }
    
    func scrollToPage(index: Int) {
        return; // STILL BUGGGGGGGGY
        
        let viewController = orderedViewControllers[index];
        
        if self.currentIndex == index {
            return;
        }
        
        self.setViewControllers([viewController], direction: .forward, animated: true, completion: nil);
        
        self.customDelegate.updateScrollHeader(currentIndex: self.currentIndex, index: index, progress: 1);
        self.customDelegate.updateHeaderAndView(index: index, progress: 1);

        self.currentIndex = index;
        self.transitionDone = true;
    }
    
    // MARK: ScrollView Delegates
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = scrollView.contentOffset;
        
        if currentIndex == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        } else if currentIndex == 2 && scrollView.contentOffset.x > scrollView.bounds.size.width {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        }
        
        guard !blockScrollViewDelegate else {
            return;
        }
        
        var percentComplete: CGFloat;
        percentComplete = fabs(point.x - view.frame.size.width)/view.frame.size.width;
        
        NSLog("percentComplete: %f", percentComplete);
        print(goingToIndex);
        print(transitionDone);
        
        if transitionDone {
            if percentComplete == 1 || percentComplete == 0 {
                self.blockScrollViewDelegate = true;
                return;
            }
        }
        
        self.customDelegate.updateScrollHeader(currentIndex: self.currentIndex, index: self.goingToIndex, progress: percentComplete);
        self.customDelegate.updateHeaderAndView(index: self.goingToIndex, progress: percentComplete);
    }
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if currentIndex == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        } else if currentIndex == 2 && scrollView.contentOffset.x > scrollView.bounds.size.width {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        }
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newViewController(name: "Settings"),
                self.newViewController(name: "Hidden"),
                self.newViewController(name: "Calculator")]
    }();
    
    private func newViewController(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(name)ViewController")
    }
}

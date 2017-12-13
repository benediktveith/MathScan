//
//  MainViewController.swift
//  MathScan
//
//  Created by Benedikt Veith on 10.11.17.
//  Copyright © 2017 benedikt-veith. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, ViewControllerDelegate {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerOutlineView: UIView!
    @IBOutlet weak var headerScrollView: UIScrollView!
    
    var scanViewController: ViewController?
    
    override func viewDidLoad() {
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embedSegue") {
            let vc = segue.destination as! ViewController;
            vc.customDelegate = self;
            
            self.scanViewController = vc;
        }
    }
    
    func updateScrollHeader(currentIndex: Int, index: Int, progress: CGFloat) {
        let isScrollingRight : CGFloat = (currentIndex < index) ? 1.0 : -1.0;
        
        self.headerScrollView.setContentOffset(CGPoint(x: CGFloat(40 * (currentIndex - 1)) + isScrollingRight * 40 * progress, y: 0), animated: false);
    }
    
    func updateHeaderAndView(index: Int, progress: CGFloat) {
        var progress = progress;
        
        if index == 1 {
            progress = 1 - progress;
        } else {
            progress = 0 + progress;
        }
        
        self.headerView.backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: progress);
        self.headerOutlineView.backgroundColor = UIColor.clear;
        
        if (index == 1 && progress == 0) || (index != 1 && progress == 0) {
            self.headerOutlineView.backgroundColor = UIColor.white;
        }
    }
    
    @IBAction func menuButtonTouched(_ sender: UIButton) {
        self.scanViewController?.scrollToPage(index: sender.tag);
    }
    
}

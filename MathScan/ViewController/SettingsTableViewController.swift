//
//  SettingsTableViewController.swift
//  MathScan
//
//  Created by Benedikt Veith on 15.11.17.
//  Copyright © 2017 benedikt-veith. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        self.view.roundCorners([.topLeft, .topRight], radius: 10);
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openGitHubTouched(_ sender: UIButton) {
        guard let url = URL(string: "https://github.com/benediktveith/MathScan") else {
            return;
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil);
        } else {
            UIApplication.shared.openURL(url);
        }
    }
}

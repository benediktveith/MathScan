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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

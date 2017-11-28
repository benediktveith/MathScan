//
//  CalculatorFormulaLabel.swift
//  MathScan
//
//  Created by Benedikt Veith on 23.11.17.
//  Copyright © 2017 benedikt-veith. All rights reserved.
//

import UIKit

class CalculatorFormulaLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame);
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    convenience init(frame: CGRect, text: String) {
        self.init(frame: frame);
        
        self.text = text;
        self.textColor = UIColor.black;
        self.textAlignment = .center;
    }
}

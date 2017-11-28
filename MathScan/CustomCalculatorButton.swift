//
//  CustomCalculatorButton.swift
//  MathScan
//
//  Created by Benedikt Veith on 17.11.17.
//  Copyright © 2017 benedikt-veith. All rights reserved.
//

import UIKit

extension UIColor {
    
    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
        
    }
    
}

class CustomCalculatorButton: UIButton {
    
    var isOperator: Bool = false;
    var isEqualSign: Bool = false;
    var buttonString: String = "";
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.setupButton();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        self.setupButton();
    }
    
    func setupButton() {
        self.layer.shadowColor = self.backgroundColor?.darker(by: 50)!.cgColor;
        self.layer.shadowOffset = CGSize(width: 0.0, height: 2.0);
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowRadius = 0.0;
        self.layer.masksToBounds = false;
    }
}

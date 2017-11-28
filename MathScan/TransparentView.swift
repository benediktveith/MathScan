//
//  TransparentView.swift
//  MathScan
//
//  Created by Benedikt Veith on 13.11.17.
//  Copyright © 2017 benedikt-veith. All rights reserved.
//

import UIKit

protocol TransparentViewDelegate: class {
    func point(inside point: CGPoint, with event: UIEvent?);
}

class TransparentView : UIView {
    var delegate : TransparentViewDelegate!;
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        self.delegate.point(inside: point, with: event);
        
        return true;
    }
}

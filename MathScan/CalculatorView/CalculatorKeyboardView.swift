//
//  CalculatorKeyboardView.swift
//  MathScan
//
//  Created by Benedikt Veith on 16.11.17.
//  Copyright © 2017 benedikt-veith. All rights reserved.
//

import UIKit

protocol KeyboardDelegate: class {
    func keyTapped(character: String);
    func deleteTapped();
}

class CalculatorKeyboardView : UIView {
    weak var delegate: KeyboardDelegate?;
    
    @IBOutlet weak var oneButton: CustomCalculatorButton!
    @IBOutlet weak var twoButton: CustomCalculatorButton!
    @IBOutlet weak var threeButton: CustomCalculatorButton!
    @IBOutlet weak var fourButton: CustomCalculatorButton!
    @IBOutlet weak var fiveButton: CustomCalculatorButton!
    @IBOutlet weak var sixButton: CustomCalculatorButton!
    @IBOutlet weak var sevenButton: CustomCalculatorButton!
    @IBOutlet weak var eightButton: CustomCalculatorButton!
    @IBOutlet weak var nineButton: CustomCalculatorButton!
    @IBOutlet weak var zeroButton: CustomCalculatorButton!
    
    @IBOutlet weak var deleteButton: CustomCalculatorButton!
    @IBOutlet weak var divButton: CustomCalculatorButton!
    @IBOutlet weak var multButton: CustomCalculatorButton!
    @IBOutlet weak var minusButton: CustomCalculatorButton!
    @IBOutlet weak var plusButton: CustomCalculatorButton!
    @IBOutlet weak var equalButton: CustomCalculatorButton!
    @IBOutlet weak var dotButton: CustomCalculatorButton!
    
    @IBOutlet weak var moveLeft: CustomCalculatorButton!
    @IBOutlet weak var moveRight: CustomCalculatorButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        self.setupCalculatorKeyboard();
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.setupCalculatorKeyboard();
    }
    
    func setupCalculatorKeyboard() {
        let calculatorView = Bundle.main.loadNibNamed("CalculatorKeyboardView", owner: self, options: nil)![0] as! UIView
        
        calculatorView.layer.shadowColor = UIColor.black.cgColor;
        calculatorView.layer.shadowOpacity = 0.5;
        calculatorView.layer.shadowOffset = CGSize.zero;
        calculatorView.layer.shadowRadius = 3;
        calculatorView.layer.masksToBounds = false;
        
        self.addSubview(calculatorView);
        
        calculatorView.frame = self.bounds;
        
        oneButton.buttonString = "1";
        twoButton.buttonString = "2";
        threeButton.buttonString = "3";
        fourButton.buttonString = "4";
        fiveButton.buttonString = "5";
        sixButton.buttonString = "6";
        sevenButton.buttonString = "7";
        eightButton.buttonString = "8";
        nineButton.buttonString = "9";
        zeroButton.buttonString = "0";
        
        dotButton.buttonString = ".";
        
        plusButton.buttonString = "+";
        plusButton.isOperator = true;
        
        minusButton.buttonString = "-";
        minusButton.isOperator = true;
        
        divButton.buttonString = ":";
        divButton.isOperator = true;
        
        multButton.buttonString = "*";
        multButton.isOperator = true;
        
        equalButton.buttonString = "=";
        equalButton.isEqualSign = true;
        
        divButton.isEnabled = false;
        multButton.isEnabled = false;
        
        moveLeft.buttonString = "left";
        moveRight.buttonString = "right";
    }
    
    @IBAction func deleteTouched(_ sender: CustomCalculatorButton) {
        self.delegate?.deleteTapped();
    }
    
    @IBAction func buttonTouched(_ sender: CustomCalculatorButton) {
        self.delegate?.keyTapped(character: sender.buttonString);
    }
}

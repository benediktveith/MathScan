//
//  CalculatorViewController.swift
//  MathScan
//
//  Created by Benedikt Veith on 15.11.17.
//  Copyright © 2017 benedikt-veith. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController, FormulaDelegate {
    
//    @IBOutlet weak var calculatorTextField: CustomCalculatorTextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var solutionView: UIView!
    @IBOutlet weak var solutionLabel: UILabel!
    
    var toggle: Bool = true;
    var calcFormulaView: CalculatorFormulaView!
    
    override func viewDidLoad() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.toggleKeyboard));
        tap.cancelsTouchesInView = false;
        scrollView.addGestureRecognizer(tap);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let scannedValue = UserDefaults.standard.string(forKey: AppDefaultStorage.keyScannedValued) {
            if scannedValue != self.calcFormulaView.calculatorValue as String {
                UserDefaults.standard.set(self.calcFormulaView.calculatorValue as String, forKey: AppDefaultStorage.keyScannedValued);
            }
        } else {
            UserDefaults.standard.set(self.calcFormulaView.calculatorValue as String, forKey: AppDefaultStorage.keyScannedValued);
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.calcFormulaView == nil {
            self.calcFormulaView = CalculatorFormulaView(frame: CGRect(x: 0, y: 0, width: self.scrollView.contentSize.width, height: self.scrollView.contentSize.height));
            self.calcFormulaView.delegate = self;
            
            self.scrollView.addSubview(self.calcFormulaView);
        }
        
        if let scannedValue = UserDefaults.standard.string(forKey: AppDefaultStorage.keyScannedValued) {
            self.calcFormulaView.setCalculatorValueAndUpdate(value: scannedValue);
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func toggleKeyboard() {
        calcFormulaView.toggleKeyboard(show: toggle);
        
        toggle = !toggle;
    }
    
    func formulaUpdated(formula: CalculatorFormulaView) {
        self.scrollView.contentSize = formula.frame.size;
        
        self.calculateFormula(value: formula.calculatorValue as String);
    }
    
    func calculateFormula(value: String) {
        var value = value;
        
        let validationHelper = ValidationHelper();
        let validationResult = validationHelper.validateText(recognizedText: value);
        
        guard validationResult["valid"] as! Bool == true else {
            return;
        }
        
        value = validationResult["text"] as! String;
        
        let calculator = MathCalculator();
        let calculationResult = calculator.solveEquation(text: value);
        
        value = calculationResult["text"] as! String;
        
        let formatter = FormatHelper();
        let formattedResult = formatter.formatAndBeautifySolution(solution: value);
        
        self.solutionView.isHidden = false;
        self.solutionLabel.text = formattedResult;
    }
}

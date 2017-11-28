//
//  CalculatorFormulaView.swift
//  MathScan
//
//  Created by Benedikt Veith on 23.11.17.
//  Copyright © 2017 benedikt-veith. All rights reserved.
//

import UIKit

protocol FormulaDelegate {
    func formulaUpdated(formula: CalculatorFormulaView);
}

class CalculatorFormulaView: UIView, CalculatorBlockDelegate {
    var delegate : FormulaDelegate!;
    let formulaHelper = FormulaHelper();
    
    var currentActiveBlock = 0;
    var blockArray: [CalculatorInputTextField] = [];
    
    var calculatorValue: NSMutableString = "";
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        
        self.setupFormulaView();
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        self.setupFormulaView();
    }
    
    func setupFormulaView() {
        let placeholderTextField = CalculatorInputTextField(frame: CGRect(x: 16, y: 8, width: 0, height: 30), blockId: 0, isPlaceholderBlock: false, placeholderText: "Enter equation here...");
        placeholderTextField.sizeToCorrectWidth();
        placeholderTextField.customDelegate = self;
        
        blockArray.append(placeholderTextField);
        self.addSubview(placeholderTextField);
    }
    
    func toggleKeyboard(show: Bool) {
        let activeTextField = self.blockArray[self.currentActiveBlock];
        
        if show {
            activeTextField.becomeFirstResponder();
        } else {
            activeTextField.resignFirstResponder();
        }
    }
    
    func toggleFirstBlockPlaceholderText(show: Bool) {
        let activeTextField = self.blockArray[0];
        
        if show {
            activeTextField.placeholder = "Enter equation here...";
        } else {
            activeTextField.placeholder = "";
        }
        
        activeTextField.sizeToCorrectWidth();
    }
    
    func createLayoutOfAllSubviews() {
        let basicOperatorParts = self.formulaHelper.getBasicOperatorsFromText(text: self.calculatorValue as String);
        let basicOperatorSeperatedParts = self.formulaHelper.seperateTextWithBasicOperators(text: self.calculatorValue as String);
        
        if self.calculatorValue.length == 0 {
            self.toggleFirstBlockPlaceholderText(show: true);
            self.subviews.forEach { $0.removeFromSuperview(); }
            self.addSubview(self.blockArray[0]);
            self.toggleKeyboard(show: true);
            
            return;
        }
        
        var addSubviewList: [UIView] = [];
        for (index, operatorPart) in basicOperatorParts.enumerated() {
            if index == 0 {
                let textField = CalculatorInputTextField(frame: CGRect(x: 16, y: 8, width: 0, height: 30), blockId: 0, isPlaceholderBlock: false, placeholderText: "Enter equation here...");
                textField.customDelegate = self;
                textField.content = NSMutableString(string: basicOperatorSeperatedParts[index]);
                textField.text = basicOperatorSeperatedParts[index];
                textField.sizeToCorrectWidth();
                blockArray[index] = textField;
                
                if basicOperatorSeperatedParts[index].isEmpty {
                    self.toggleFirstBlockPlaceholderText(show: false);
                }
                
                addSubviewList.append(textField);
            }
            
            if operatorPart.isEmpty {
                continue;
            }
            
            let operatorLabel = CalculatorFormulaLabel(frame: CGRect(x: blockArray[index].frame.maxX, y: 8, width: 20, height: 30), text: operatorPart);
            
            // Right Side relative to operator
            var rightSideNumber = "";
            if basicOperatorSeperatedParts.count < index + 2 {
                rightSideNumber = "";
            } else {
                rightSideNumber = basicOperatorSeperatedParts[index + 1];
            }

            let rightBlockTextField: CalculatorInputTextField = CalculatorInputTextField(frame: CGRect(x: operatorLabel.frame.maxX, y: 8, width: 0, height: 30), blockId: index + 1, isPlaceholderBlock: !rightSideNumber.isEmpty, placeholderText: "");
            rightBlockTextField.customDelegate = self;
            rightBlockTextField.content = NSMutableString(string: rightSideNumber);
            rightBlockTextField.text = rightSideNumber;
            rightBlockTextField.sizeToCorrectWidth();
            
            if blockArray.count < index + 2 {
                blockArray.append(rightBlockTextField);
            } else {
                blockArray[index + 1] = rightBlockTextField;
            }
            
            addSubviewList.append(operatorLabel);
            addSubviewList.append(rightBlockTextField);
        }
        
        self.subviews.forEach { $0.removeFromSuperview(); }
        
        var totalWidth = CGFloat(0.0);
        for subview in addSubviewList {
            self.addSubview(subview);
            totalWidth = subview.frame.maxX;
        }
        
        self.toggleKeyboard(show: true);
        self.frame = CGRect(x: 0.0, y: 0.0, width: totalWidth, height: self.frame.height);
        
        self.delegate.formulaUpdated(formula: self);
    }
    
    func insertIntoCalculatorValue(value: String, at blockID: Int, replace: Bool = false) {
        let basicOperatorParts = self.formulaHelper.getBasicOperatorsFromText(text: self.calculatorValue as String);
        var basicOperatorSeperatedParts = self.formulaHelper.seperateTextWithBasicOperators(text: self.calculatorValue as String);
        
        if basicOperatorSeperatedParts.count == 0 {
            self.calculatorValue = NSMutableString(string: value);
            return;
        }
        
        if basicOperatorSeperatedParts.count < blockID + 1 {
            basicOperatorSeperatedParts.append("");
        }
        
        var blockPart = basicOperatorSeperatedParts[blockID];
        if replace {
            blockPart = value;
        } else {
            blockPart = blockPart + value;
        }
        
        basicOperatorSeperatedParts[blockID] = blockPart;
        
        var newCalculatorValue = "";
        for (index, part) in basicOperatorSeperatedParts.enumerated() {
            newCalculatorValue = newCalculatorValue + part;
            
            if basicOperatorParts.count > index {
                newCalculatorValue = newCalculatorValue + basicOperatorParts[index];
            }
        }
        
        self.calculatorValue = NSMutableString(string: newCalculatorValue);
    }
    
    func removeFromCalculatorValue(at blockID: Int) {
        var basicOperatorParts = self.formulaHelper.getBasicOperatorsFromText(text: self.calculatorValue as String);
        var basicOperatorSeperatedParts = self.formulaHelper.seperateTextWithBasicOperators(text: self.calculatorValue as String);
        basicOperatorParts.remove(at: blockID - 1);
        
        if basicOperatorSeperatedParts.count > blockID {
            basicOperatorSeperatedParts.remove(at: blockID);
        }
        
        var newCalculatorValue = "";
        for (index, part) in basicOperatorSeperatedParts.enumerated() {
            newCalculatorValue = newCalculatorValue + part;
            
            if basicOperatorParts.count > index {
                newCalculatorValue = newCalculatorValue + basicOperatorParts[index];
            }
        }
        
        self.calculatorValue = NSMutableString(string: newCalculatorValue);
        if self.blockArray.count > blockID {
            self.blockArray.remove(at: blockID);
        }
    }
    
    // MARK: Textfield Delegates
    
    func blockUpdated(content: String, id: Int) {
        self.insertIntoCalculatorValue(value: content, at: id, replace: true);
        self.createLayoutOfAllSubviews();
    }
    
    func blockDeleted(id: Int) {
        if id == 0 {
            return;
        }
        
        self.removeFromCalculatorValue(at: id);
        self.currentActiveBlock = self.currentActiveBlock - 1;
        self.createLayoutOfAllSubviews();
    }
    
    func operatorPressed(at id: Int, operatorString: String) {
        self.insertIntoCalculatorValue(value: operatorString, at: id);
        self.currentActiveBlock = id + 1;
        
        self.createLayoutOfAllSubviews();
    }
    
    func didBecomeActive(id: Int, activate: Bool) {
        if activate {
            if id < 0 || blockArray.count < id + 1 {
                return;
            }
            
            blockArray[id].becomeFirstResponder();
        }
        
        self.currentActiveBlock = id;
    }
}

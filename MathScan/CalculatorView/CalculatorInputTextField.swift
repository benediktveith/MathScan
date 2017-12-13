//
//  CalculatorInputTextField.swift
//  MathScan
//
//  Created by Benedikt Veith on 23.11.17.
//  Copyright © 2017 benedikt-veith. All rights reserved.
//

import UIKit

extension String {
    func textWidth(font: UIFont?) -> CGFloat {
        let attributes = font != nil ? [NSAttributedStringKey.font: font!] : [:]
        return self.size(withAttributes: attributes).width
    }
}

protocol CalculatorBlockDelegate: class {
    func blockUpdated(content: String, id: Int);
    func blockDeleted(id: Int);
    func didBecomeActive(id: Int, activate: Bool);
    func operatorPressed(at id: Int, operatorString: String);
}

class CalculatorInputTextField: UITextField, KeyboardDelegate, UITextFieldDelegate {
    weak var customDelegate: CalculatorBlockDelegate?;
    
    var blockID: Int = 0;
    var isPlaceholderBlock: Bool = false;
    var content: NSMutableString = "";
    var isActive: Bool = false;
    
    convenience init(frame: CGRect, blockId: Int, isPlaceholderBlock: Bool, placeholderText: String) {
        self.init(frame: frame);
        
        self.blockID = blockId;
        self.isPlaceholderBlock = isPlaceholderBlock;
        
        self.placeholder = placeholderText;
        self.font = UIFont(name: "Courier New Bold", size: 18);
        self.borderStyle = .none;
        self.backgroundColor = UIColor.clear;
        self.tintColor = UIColor(displayP3Red: 231/255, green: 76/255, blue: 60/255, alpha: 1);
        self.textColor = UIColor.black;
        self.textAlignment = .right;
        self.delegate = self;
        
        self.setupCustomKeyboard();
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame);
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
    }
    
    func getCursorPosition() -> Int {
        let selectedRange = self.selectedTextRange;
        let cursorPosition = self.offset(from: self.beginningOfDocument, to: (selectedRange?.start)!);
        
        
        return cursorPosition;
    }
    
    func sizeToCorrectWidth() {
        if (self.text?.isEmpty)! {
            if (self.placeholder == nil || (self.placeholder?.isEmpty)!) {
                self.frame.size = CGSize(width: 20, height: 30);
                self.fixCalculatorLayout();
                return;
            }
            let width = self.placeholder?.textWidth(font: self.font);
            self.frame.size = CGSize(width: width!, height: 30);
            self.fixCalculatorLayout();
            return;
        }
        let width = (self.text?.textWidth(font: self.font))!;
        self.frame.size = CGSize(width: width, height: 30);
        self.fixCalculatorLayout();
    }
    
    func fixCalculatorLayout() {
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer(); }
        
        if (self.text?.isEmpty)! {
            if (self.placeholder == nil || (self.placeholder?.isEmpty)!) {
                let dottedBorder = CAShapeLayer();
                dottedBorder.strokeColor = UIColor.darkGray.cgColor;
                dottedBorder.fillColor = nil;
                dottedBorder.lineDashPattern = [2, 2];
                dottedBorder.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 0).cgPath;
                dottedBorder.frame = self.bounds;
                self.layer.addSublayer(dottedBorder);
                self.layer.masksToBounds = true;
                
                self.backgroundColor = UIColor.lightGray.lighter();
                self.textAlignment = .left;
                return;
            }
            
            if !self.isActive {
                self.backgroundColor = UIColor.clear;
            }
            self.textAlignment = .left;
            return;
        }
        
        self.backgroundColor = UIColor.clear;
        self.textAlignment = .right;
    }
    
    func setupCustomKeyboard() {
        let calculatorView = CalculatorKeyboardView(frame: CGRect(x: 0, y: 0, width: 0, height: 240));
        calculatorView.delegate = self;
        
        self.inputView = calculatorView;
    }
    
    func keyTapped(character: String) {
        let cursorPos = self.getCursorPosition();
        
        if character == "+" || character == "-" || character == "=" {
            self.customDelegate?.operatorPressed(at: self.blockID, operatorString: character);
            return;
        }
        
        if character == "left" || character == "right" {
            if character == "left" {
                self.customDelegate?.didBecomeActive(id: blockID - 1, activate: true);
            } else if character == "right" {
                self.customDelegate?.didBecomeActive(id: blockID + 1, activate: true);
            }
            return;
        }
        
        self.content.insert(character, at: cursorPos);
        self.text = content as String;
        self.customDelegate?.blockUpdated(content: self.content as String, id: self.blockID);
    }
    
    func deleteTapped() {
        guard self.content.length > 0 else {
            self.customDelegate?.blockDeleted(id: self.blockID);
            return;
        }
        let cursorPos = self.getCursorPosition();
        let rangeCursorPos = (cursorPos > 0) ? cursorPos - 1 : cursorPos;
        
        self.content.deleteCharacters(in: NSMakeRange(rangeCursorPos, 1));
        self.text = content as String;
        self.customDelegate?.blockUpdated(content: self.content as String, id: self.blockID);
    }
    
    func didBecomeActive() {
        self.isActive = true;
        self.backgroundColor = UIColor.white;
        
        self.customDelegate?.didBecomeActive(id: self.blockID, activate: false);
    }
    
    func didBecomeDeactive() {
        self.isActive = false;
        self.fixCalculatorLayout();
    }
    
    // MARK: TEXTFIELD DELEGATES
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.didBecomeActive();
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.didBecomeDeactive();
    }
}

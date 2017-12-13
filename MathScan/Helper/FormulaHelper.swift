//
//  FormulaHelper.swift
//  MathScan
//
//  Created by Benedikt Veith on 24.11.17.
//  Copyright © 2017 benedikt-veith. All rights reserved.
//

import Foundation

class FormulaHelper {
    
    let basicOperators = CharacterSet(charactersIn: "+-=");
    
    func seperateTextWithBasicOperators(text: String) -> [String] {
        let firstOperatorIndex = text.findIndexOfFirstCharacterFromSet(characterSet: basicOperators, ignoreFirstChar: false);
        
        guard firstOperatorIndex != nil else {
            if !text.isEmpty {
                return [text];
            }
            
            return [];
        }
        
        let restText = String(text[text.index(after: firstOperatorIndex!)...]);
        let firstPartString = String(text[..<firstOperatorIndex!]);
        
        guard restText.isEmpty else {
            var recursiveParts = self.seperateTextWithBasicOperators(text: restText);
            recursiveParts.insert(firstPartString, at: 0);
            
            return recursiveParts;
        }
        
        return [firstPartString];
    }
    
    func getBasicOperatorsFromText(text: String) -> [String] {
        let firstOperatorIndex = text.findIndexOfFirstCharacterFromSet(characterSet: basicOperators, ignoreFirstChar: false);
        
        guard firstOperatorIndex != nil else {
            return [""];
        }
        
        let restText = String(text[text.index(after: firstOperatorIndex!)...]);
        let operatorString = String(text[firstOperatorIndex!]);
        
        guard restText.isEmpty else {
            var recursiveParts = self.getBasicOperatorsFromText(text: restText);
            recursiveParts.insert(operatorString, at: 0);
            
            return recursiveParts;
        }
        
        return [operatorString];
    }
    
}

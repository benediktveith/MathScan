//
//  FormatHelper.swift
//  MathScan
//
//  Created by Benedikt Veith on 10.10.17.
//  Copyright © 2017 benedikt-veith. All rights reserved.
//

import Foundation

extension String {
    /// Converting variable to a number
    /// - Parameter variable: String
    /// - Returns: String -> Number
    func variableToNumber(variable: String) -> String {
        var number = self;
        
        if !variable.isEmpty {
            // 2x -> 2; x -> 1
            if self == variable || self == "+\(variable)" || self == "-\(variable)" {
                if self == "-\(variable)" {
                    number = "-1";
                } else {
                    number = "1";
                }
            } else {
                number = self.dropLast().description;
            }
        }
        
        return number;
    }
    
    /// Checking if String is an empty number(0; 0.0)
    /// - Parameter variable: String
    /// - Returns: Bool
    func isEmptyNumber(variable: String = "") -> Bool {
        if self.isEmpty {
            return true;
        }
        
        if self == "0.0" {
            return true;
        }
        
        if self == "0" {
            return true;
        }
        
        guard variable.isEmpty else {
            if self.last?.description == variable {
                if self.count == 1 {
                    return false;
                }
                
                let numericValue = String(self.dropLast());
                return numericValue.isEmptyNumber(variable: variable);
            }
            
            return false;
        }
        
        return false;
    }
}

extension Double {
    /// Rounding Double
    /// - Returns: Double
    func roundedTwoDecimals() -> Double {
        return (self*100).rounded() / 100;
    }
    
    /// Converting Double to correct String Format
    /// - Returns: Rounded Double or Integer Value as String
    func convertToCorrectFormat() -> String {
        let isInteger = self.truncatingRemainder(dividingBy: 1) == 0;
        
        if isInteger {
            return String(Int(self));
        }
        
        return String(self.roundedTwoDecimals());
    }
    
    /// Converting Double to Valid String
    /// e.g. 3.0 -> +3.0; -1.0x -> -x;
    /// - Parameter variable: String -> Optional Variable
    /// - Returns: String
    func toValidString(variable: String = "") -> String {
        var returnValue = String(self);
        
        if self == 0 {
            return returnValue;
        }
        
        if self > 0.0 {
            returnValue = "+" + returnValue;
        }
        
        guard variable.isEmpty else {
            if self == 1 {
                returnValue = "+";
            } else if self == -1 {
                returnValue = "-";
            }
            
            returnValue = returnValue + variable;
            return returnValue;
        }
        
        return returnValue;
    }
}

class FormatHelper {
    /// Validation Helper Class Reference
    let validationHelper = ValidationHelper();
    
    /// Removes unneccessary 0 values inside of the given text
    /// - Parameter text: String
    /// - Returns: String
    func createTermFromCalculatedString(text: String) -> String {
        
        let calculatedStringParts = text.components(separatedBy: " ");
        let variable = self.validationHelper.getVariable(term: calculatedStringParts[0]);
        
        guard calculatedStringParts.count > 1 else {
            guard !calculatedStringParts[0].isEmptyNumber(variable: variable) else {
                return "0";
            }
            
            return calculatedStringParts[0];
        }
        
        guard !calculatedStringParts[0].isEmptyNumber(variable: variable) else {
            guard !calculatedStringParts[1].isEmptyNumber(variable: variable) else {
                return "0";
            }
            
            return calculatedStringParts[1];
        }
        
        guard !calculatedStringParts[1].isEmptyNumber(variable: variable) else {
            return calculatedStringParts[0];
        }
        
        return calculatedStringParts[0] + calculatedStringParts[1];
    }
    
    /// Formats Term / Equation for Output
    /// - Parameter solution: String -> Term / Equation
    /// - Returns: String
    func formatAndBeautifySolution(solution: String) -> String {
        var equationParts = solution.components(separatedBy: "=");
        
        for (index, equationPart) in equationParts.enumerated() {
            let termParts = self.validationHelper.seperateTermInParts(term: equationPart);
            
            for (tIndex, term) in termParts.enumerated() {
                let hasVariable = term["variable"] as! Bool;
                var part = term["text"] as! String;
                let variable = self.validationHelper.getVariable(term: part);
                
                if hasVariable {
                    part = part.variableToNumber(variable: variable);
                }
                
                part = Double(part)!.convertToCorrectFormat();
                
                if hasVariable {
                    if Double(part)! == 1 {
                        part = variable;
                    } else if Double(part)! == -1 {
                        part = "-" + variable;
                    } else {
                        part = part + variable;
                    }
                }
                
                if tIndex == 0 {
                    equationParts[index] = part;
                } else {
                    if Double(part)! > 0 {
                        part = "+" + part;
                    }
                    
                    equationParts[index] = equationParts[index] + part;
                }
            }
        }
        
        guard equationParts.count > 1 else {
            return equationParts[0];
        }
        
        return equationParts[0] + "=" + equationParts[1];
    }
    
}

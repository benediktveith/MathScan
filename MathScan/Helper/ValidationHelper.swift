//
//  ValidationHelper.swift
//  MathScan
//
//  Created by Benedikt Veith on 10.10.17.
//  Copyright © 2017 benedikt-veith. All rights reserved.
//

import Foundation
import TesseractOCR

extension String {
    
    /// Get Character at Index of String
    /// - Parameter i: Int -> Index
    /// - Returns: Character
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)];
    }
    
    /// Get Index of first found character of CharacterSet in String
    /// - Parameter characterSet: CharacterSet
    /// - Returns: Index
    func findIndexOfFirstCharacterFromSet(characterSet: CharacterSet, ignoreFirstChar: Bool = true) -> Index? {
        var charIndex = -1;
        
        for (index, char) in self.enumerated() {
            guard char.description.rangeOfCharacter(from: characterSet) != nil else {
                continue;
            }
            
            if index == 0 && ignoreFirstChar {
                continue;
            }
            
            charIndex = index;
            break;
        }
        
        guard charIndex != -1 else {
            return nil;
        }
        
        return self.index(self.startIndex, offsetBy: charIndex);
    }
}

/// Validated recognized Text
class ValidationHelper {
    
    /// Valid Basic Characters of an Equation
    let validBasicCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0987654321");
    
    /// Valid Operator Characters of an Equation
    let validOperatorCharacters = NSMutableCharacterSet(charactersIn: "+-");
    
    /// Valid Algebraic Sign Characters of an Equation
    let validAlgebraicSignCharacters = CharacterSet(charactersIn: "+-");
    
    /// Valid Special Characters of an Equation
    let validSpecialCharacters = CharacterSet(charactersIn: ".=");
    
    
    /// Validates the Text
    /// - Parameter recognizedText: String
    /// - Parameter recognizedCharacter: [NSArray] -> Array of all recognized Characters and its Tesseract recognized possibilities
    /// - Returns: NSDictionary -> Text valid true / false and valid Text
    func validateText(recognizedText: String, recognizedCharacter: [NSArray]) -> NSDictionary {
        guard self.checkTextForSingleVariable(text: recognizedText) else {
            return ["valid": false];
        }
        
        let text = self.correctText(recognizedText: recognizedText, recognizedCharacter: recognizedCharacter);
        
        guard !text.isEmpty else {
            return ["valid": false];
        }
        
        guard text.contains("=") else {
            return ["valid": self.validateTerm(term: text), "text": text];
        }
        
        guard text.count >= 3 else {
            return ["valid": false];
        }
        
        let termsFromEquationArray = text.components(separatedBy: "=");
        
        guard termsFromEquationArray.count <= 2 else {
            return ["valid": false];
        }
        
        for term in termsFromEquationArray {
            guard self.validateTerm(term: term, fromEquation: true) else {
                return ["valid": false];
            }
        }
        
        return ["valid": true, "text": text];
    }
    
    /// Validates Term and its parts
    /// - Parameter term: String
    /// - Parameter fromEquation: Bool -> Wheter Term is from Equation or single term
    /// - Returns: Bool -> Term valid true / false
    func validateTerm(term: String, fromEquation: Bool = false) -> Bool {
        
        // No Operators ? No need to calculate it!
        if !fromEquation && term.rangeOfCharacter(from: validOperatorCharacters as CharacterSet) == nil {
            return false;
        }
        
        // No valid Basic Char? No need to calculate it!
        guard term.rangeOfCharacter(from: validBasicCharacters) != nil else {
            return false;
        }
        
        let validOperatorCharactersCopy = validOperatorCharacters.mutableCopy() as! NSMutableCharacterSet;
        validOperatorCharactersCopy.removeCharacters(in: "-");
        
        // First Char could be a - (as Algebraic Sign) otherwise no Operator allowed , Last Char can never be Operator!
        guard term.first?.description.rangeOfCharacter(from: validOperatorCharactersCopy as CharacterSet) == nil && term.last?.description.rangeOfCharacter(from: validOperatorCharacters as CharacterSet) == nil else {
            return false;
        }
        
        
        let termParts = self.seperateTermInParts(term: term);
        
        for part in termParts {
            var part = part["text"] as! String;
            if part.first?.description.rangeOfCharacter(from: validOperatorCharacters as CharacterSet) != nil {
                part = String(part.dropFirst());
            }
            
            guard part.rangeOfCharacter(from: validBasicCharacters) != nil else {
                return false;
            }
            
            guard checkVariableAmountAndPosition(part: part) else {
                return false;
            }
            
            guard checkNumberAmount(part: part) else {
                return false;
            }
            
            guard checkCommataAmount(part: part) else {
                return false;
            }
        }
        
        return true;
    }
    
    /// Removes unneccessary Characters from Text and corrects possible incorrect recognized characters
    /// - Parameter recognizedText: String
    /// - Parameter recognizedCharacter: [NSArray] -> Array of all recognized Characters and its Tesseract recognized possibilities
    /// - Returns: String -> Corrected Text
    func correctText(recognizedText: String, recognizedCharacter: [NSArray]) -> String {
        var text = recognizedText.replacingOccurrences(of: " ", with: "");
        
        // Remove unneccessary chars
        var recognizedCharacters = CharacterSet(charactersIn: recognizedText);
        recognizedCharacters.subtract(validBasicCharacters);
        recognizedCharacters.subtract(validSpecialCharacters);
        recognizedCharacters.subtract(validOperatorCharacters as CharacterSet);
        text = text.components(separatedBy: recognizedCharacters).joined();
        text = text.replacingOccurrences(of: "'`´‘", with: "");
        
        for (index, characterChoice) in recognizedCharacter.enumerated() {
            guard characterChoice.count > 0 else {
                continue;
            }
            
            let mostConfidentCharacter = characterChoice[0] as! G8RecognizedBlock;
            
            guard index < text.count else {
                continue;
            }
            
            if text[index].description != mostConfidentCharacter.text {
                if (mostConfidentCharacter.text == "—" || mostConfidentCharacter.text == "-") {
                    // Index before & after is no operator
                    guard index > 0 && text[index - 1].description.rangeOfCharacter(from: validOperatorCharacters as CharacterSet) == nil else {
                        continue;
                    }
                    
                    guard text[index].description.rangeOfCharacter(from: validOperatorCharacters as CharacterSet) == nil else {
                        continue;
                    }
                    
                    text.insert("-", at: text.index(text.startIndex, offsetBy: index));
                } else if (mostConfidentCharacter.text == "1" && text[index].description == "l") {
                    text.insert("1", at: text.index(text.startIndex, offsetBy: index));
                }
                
            }
        }
        
        print(text);
        
        return text;
    }
    
    /// Checking if Term / Equation contains only one variable
    /// - Parameter text: String -> Term / Equation
    /// - Returns: Bool
    func checkTextForSingleVariable(text: String) -> Bool {
        let variables = text.components(separatedBy: NSCharacterSet.letters.inverted).joined();
        
        if variables.count > 1 {
            let firstFoundVariable = variables[0].description;
            for i in 0..<variables.count {
                guard variables[i].description == firstFoundVariable else {
                    return false;
                }
            }
        }
        
        return true;
    }
    
    //MARK: Term Validation and Seperation
    
    /// Checking if Term part contains only one variable and if it is on the correct position
    /// - Parameter part: String -> Term Part
    /// - Returns: Bool
    func checkVariableAmountAndPosition(part: String) -> Bool {
        let variable = part.components(separatedBy: NSCharacterSet.letters.inverted).joined();
        
        guard variable.count <= 1 else {
            return false;
        }
        
        if !variable.isEmpty {
            guard part.last?.description == variable else {
                return false;
            }
        }
        
        return true;
    }
    
    /// Check if Term Part contains multiple numeric values
    /// - Parameter: String -> Term Part
    /// - Returns: Bool
    func checkNumberAmount(part: String) -> Bool {
        guard part.first?.description.rangeOfCharacter(from: NSCharacterSet.decimalDigits) != nil else {
            if part.count <= 1 {
                return true;
            }
            
            return false;
        }
        
        let numberParts = part.components(separatedBy: NSCharacterSet.letters);
        
        var numbsFounds = 0;
        for number in numberParts {
            guard number.count > 0 else {
                continue;
            }
            numbsFounds = numbsFounds + 1;
        }
        
        return numbsFounds <= 1
    }
    
    /// Checking if Term Part contains 0 or 1 Commatas
    /// - Parameter part: String -> Term Part
    /// - Returms: Bool
    func checkCommataAmount(part: String) -> Bool {
        let commaSeperatedParts = part.components(separatedBy: ".");
        
        if commaSeperatedParts.count > 2 {
            return false;
        }
        
        return true;
    }
    
    /// Return if Term contais an variable
    /// - Parameter term: String
    /// - Returns: Bool
    func hasVariable(term: String) -> Bool {
        let variable = term.components(separatedBy: NSCharacterSet.letters.inverted).joined();
        
        return variable.count > 0;
    }
    
    /// Return Variable from Term
    /// - Parameter term: String
    /// - Returns: String -> Variable
    func getVariable(term: String) -> String {
        let variable = term.components(separatedBy: NSCharacterSet.letters.inverted).joined();
        
        guard variable.count > 0 else {
            return "";
        }
        
        return variable[0].description;
    }
    
    /// Checking if both sides of an equation are equal
    /// - Parameter equation: String
    /// - Returns: NSDictionary -> IsEqual if it dont contains variable
    func equationSideEqual(equation: String) -> NSDictionary {
        let variable = self.getVariable(term: equation);
        
        guard !variable.isEmpty else {
            let termsFromEquationArray = equation.components(separatedBy: "=");
            
            if termsFromEquationArray[0] == termsFromEquationArray[1] {
                return ["isEqual": true, "hasVariable": false, "text": equation];
            }
            
            return ["isEqual": false, "hasVariable": false, "text": equation];
        }
        
        return ["hasVariable": true];
    }
    
    /// Recursive function, seperating a term in its part
    /// Seperating term based on algebraic signs(+, -)
    /// - Parameter term: String
    /// - Returns: [NSDictionary] -> Array of Dictionaries containing information about the part and wheter it contains a variable
    func seperateTermInParts(term: String) -> [NSDictionary] {
        let firstOperatorIndex = term.findIndexOfFirstCharacterFromSet(characterSet: validOperatorCharacters as CharacterSet);
        
        guard firstOperatorIndex != nil else {
            if !term.isEmpty {
                let hasVariable = self.hasVariable(term: term);
                return [["text": term, "variable": hasVariable]];
            }
            
            print("Error seperating term: " + term);
            return [];
        }
        
        let restTerm = String(term[firstOperatorIndex!...]);
        let firstPartString = String(term[..<firstOperatorIndex!]);
        let hasVariable = self.hasVariable(term: firstPartString);
        
        guard restTerm.isEmpty else {
            var recursiveParts = self.seperateTermInParts(term: restTerm);
            recursiveParts.insert(["text": firstPartString, "variable": hasVariable], at: 0);
            
            return recursiveParts;
        }
        
        return [["text": firstPartString, "variable": hasVariable]];
    }
}

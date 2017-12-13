//
//  MathCalculator.swift
//  MathScan
//
//  Created by Benedikt Veith on 10.10.17.
//  Copyright © 2017 benedikt-veith. All rights reserved.
//

import Foundation

/// Calculating recognized Text
class MathCalculator {
    
    /// ValidationHelper Class Reference
    let validationHelper = ValidationHelper();
    
    /// FormatHelper Class Reference
    let formatHelper = FormatHelper();
    
    /// Solving Terms & Equation
    /// - Parameter text: String -> Term or Equation
    /// - Returns: NSDictionary -> Solved equation or Calculated term
    func solveEquation(text: String) -> NSDictionary {
        guard text.contains("=") else {
            let calculatedTerm = self.solveTerm(term: text);
            
            guard calculatedTerm["finished"] as! Bool == true else {
                return self.solveEquation(text: calculatedTerm["text"] as! String);
            }
            
            return ["text": calculatedTerm["text"] as! String];
        }
        
        var termsFromEquationArray = text.components(separatedBy: "=");
        var bothTermsCalculated = true;
        
        for (index, term) in termsFromEquationArray.enumerated() {
            let calculatedTerm = self.solveTerm(term: term);
            
            if calculatedTerm["finished"] as! Bool == false {
                bothTermsCalculated = false;
            }
            
            termsFromEquationArray[index] = calculatedTerm["text"] as! String;
        }
        
        guard bothTermsCalculated else {
            return self.solveEquation(text: termsFromEquationArray[0] + "=" + termsFromEquationArray[1]);
        }
        
        // Check if variable exist after calculation both sides
        var sidesEqual = self.validationHelper.equationSideEqual(equation: termsFromEquationArray[0] + "=" + termsFromEquationArray[1]);
        guard sidesEqual["hasVariable"] as! Bool == true else {
            return sidesEqual;
        }
        
        let solvedEquation = self.solveEquationToVariable(termsFromEquationArray: termsFromEquationArray);
        
        sidesEqual = self.validationHelper.equationSideEqual(equation: solvedEquation);
        guard sidesEqual["hasVariable"] as! Bool == true else {
            return sidesEqual;
        }
        
        let canceledEquation = self.cancelEquationToVariable(text: solvedEquation);
        
        return ["text": canceledEquation];
    }
    
    /// Solving Equation to one side only variable parts
    /// - Parameter termsFromEquationArray: [String] -> Both Equation Sides
    /// - Returns: String -> Solved Equation
    func solveEquationToVariable(termsFromEquationArray: [String]) -> String {
        var termsFromEquationArray = termsFromEquationArray;
        var switchTermSidesArray : [[String]] = [];
        
        for (index, term) in termsFromEquationArray.enumerated() {
            let seperatedTermParts = self.validationHelper.seperateTermInParts(term: term);
            let variable = self.validationHelper.getVariable(term: term);
            let sortedTermParts = self.getVariableAndNonVariablePartsFrom(seperatedTermParts: seperatedTermParts);
            var numericParts = sortedTermParts["numeric"] as! [String];
            var variableParts = sortedTermParts["vars"] as! [String];
            
            guard index == 1 else {
                for (index, numericString) in numericParts.enumerated() {
                    let numericValue = Double(numericString)! * -1.0;
                    let numericString = numericValue.toValidString();
                    
                    numericParts[index] = numericString;
                }
                
                switchTermSidesArray.append(numericParts);
                termsFromEquationArray[index] = variableParts.joined();
                continue;
            }

            for (index, variableString) in variableParts.enumerated() {
                var variableString = variableString.variableToNumber(variable: variable);
                let variableValue = Double(variableString)! * -1.0;
                variableString = variableValue.toValidString(variable: variable);
                
                variableParts[index] = variableString;
            }
            
            switchTermSidesArray.append(variableParts);
            termsFromEquationArray[index] = numericParts.joined();
        }
        
        if switchTermSidesArray[0].count > 0 || switchTermSidesArray[1].count > 0 {
            termsFromEquationArray[0] = termsFromEquationArray[0] + switchTermSidesArray[1].joined();
            termsFromEquationArray[1] = termsFromEquationArray[1] + switchTermSidesArray[0].joined();
            
            let leftTermResult = self.solveTerm(term: termsFromEquationArray[0]);
            let rightTermResult = self.solveTerm(term: termsFromEquationArray[1]);
            
            let newEquation = (leftTermResult["text"] as! String) + "=" + (rightTermResult["text"] as! String);
            
            if leftTermResult["finished"] as! Bool == false || rightTermResult["finished"] as! Bool == false {
                return self.solveEquation(text: newEquation)["text"] as! String;
            }
            
            return newEquation;
        }
        
        return termsFromEquationArray[0] + "=" + termsFromEquationArray[1];
    }
    
    /// Cancels Equations to its variable
    /// - Parameter text: String -> Equation
    /// - Returns: String -> Canceled Equation
    func cancelEquationToVariable(text: String) -> String {
        let termsFromEquationArray = text.components(separatedBy: "=");
        
        let variableTerm = termsFromEquationArray[0];
        let variable = self.validationHelper.getVariable(term: variableTerm);
        var numericValue = variableTerm.components(separatedBy: variable).joined();
        
        // variableTerm = x
        guard !numericValue.isEmpty else {
            return text;
        }
        
        if numericValue == "-" {
            numericValue = "-1";
        }
        
        if numericValue == "+" {
            numericValue = "1";
        }
        
        let cancelledEquation = self.cancelEquationWithNumber(text: text, number: numericValue);
        return cancelledEquation;
    }
    
    /// Cancel Equation with Number
    /// - Parameter text: String -> Equation
    /// - Parameter number: String -> Number
    /// - Returns: String -> Canceled Equation
    func cancelEquationWithNumber(text: String, number: String) -> String {
        var termsFromEquationArray = text.components(separatedBy: "=");
        
        for (index, term) in termsFromEquationArray.enumerated() {
            termsFromEquationArray[index] = self.cancelTermWithNumber(term: term, number: number);
        }
        
        return termsFromEquationArray[0] + "="  + termsFromEquationArray[1];
    }
    
    // MARK: Term Solving & Calculation
    
    /// Solving Term by seperating it to variable and non variable parts; Should be changed later
    /// - Parameter term: String -> Term
    /// - Returns: NSDictionary -> New Calculated Term and Boolean wheter Term is finished or can be calculated again
    func solveTerm(term: String) -> NSDictionary {
        let seperatedTermParts = self.validationHelper.seperateTermInParts(term: term);
        let sortedTermParts = self.getVariableAndNonVariablePartsFrom(seperatedTermParts: seperatedTermParts);
        let variable = self.validationHelper.getVariable(term: term);

        let variableParts : [String] = sortedTermParts["vars"] as! [String];
        let numericParts : [String] = sortedTermParts["numeric"] as! [String];
        
        var calculatedVarPart = variableParts;
        var calculatedNonVarPart = numericParts;
        
        if variableParts.count > 1 {
            calculatedVarPart = self.calculateTerm(seperatedTermParts: variableParts, variable: variable);
        }
        
        if numericParts.count > 1 {
            calculatedNonVarPart = self.calculateTerm(seperatedTermParts: numericParts);
        }
        
        var finished = true;
        if calculatedVarPart.count > 1 || calculatedNonVarPart.count > 1 {
            finished = false;
        }
        
        let calculatedTerm = formatHelper.createTermFromCalculatedString(text: "\(calculatedVarPart.joined()) \(calculatedNonVarPart.joined())");
        return ["finished": finished, "text": calculatedTerm];
    }
    
    /// Cancels Term with Number
    /// - Parameter term: String -> Term
    /// - Parameter Number: String -> Number
    /// - Returns: String -> Canceled Term
    func cancelTermWithNumber(term: String, number: String) -> String {
        let seperatedTermParts = self.validationHelper.seperateTermInParts(term: term);
        var calculatedTermParts : [String] = [];
        let variable = self.validationHelper.getVariable(term: term);
        
        for part in seperatedTermParts {
            var numeric = part["text"] as! String;
            
            if !variable.isEmpty {
                if numeric.contains(variable) {
                    // 2x -> 2; x -> 1
                    numeric = numeric.variableToNumber(variable: variable);
                    
                    let calculatedResult = self.calculate(number: numeric, withNumber: number, operatorString: ":");
                    let calculatedValue = calculatedResult.toValidString(variable: variable);
                    
                    calculatedTermParts.append(calculatedValue);
                    continue;
                }
            }
            
            let calculatedResult = self.calculate(number: numeric, withNumber: number, operatorString: ":");
            let calculatedValue = calculatedResult.toValidString();
            
            calculatedTermParts.append(calculatedValue);
        }
        
        return calculatedTermParts.joined();
    }
    
    /// Calculating first two parts together
    /// - Parameter seperatedTermParts: [String] -> Term Seperated in its parts
    /// - Parameter variable: String -> Variable
    /// - Returns: [String] -> Term Seperated Part
    func calculateTerm(seperatedTermParts: [String], variable: String = "") -> [String] {
        var seperatedTermParts = seperatedTermParts;
        let firstNumber = seperatedTermParts[0].variableToNumber(variable: variable);
        let secondNumber = seperatedTermParts[1].variableToNumber(variable: variable);
        let calculatedResult = self.calculate(number: firstNumber, withNumber: secondNumber);
        let calculatedValue = calculatedResult.toValidString(variable: variable);
        
        seperatedTermParts.removeFirst(2);
        seperatedTermParts.insert(calculatedValue, at: 0);
        
        return seperatedTermParts;
    }
    
    //MARK: Calculate
    
    /// Calculating Two Numbers
    /// - Parameter Number: String -> First Number
    /// - Parameter withNumber: String -> Second Number
    /// - Parameter operatorString: String -> optional operator, default +
    /// - Returns: Double -> Calculated Result
    func calculate(number: String, withNumber: String, operatorString: String = "+") -> Double {
        var result = 0.0;
        
        switch operatorString {
        case "+":
            result = Double(number)! + Double(withNumber)!;
            break;
        case ":":
            result = Double(number)! / Double(withNumber)!;
            break;
        default:
            result = Double(number)! + Double(withNumber)!;
        }
        
        return result;
    }
    
    // MARK: Helper
    
    /// Order Term Parts in Variable and Non Variable Parts; Should be changed later
    /// - Parameter seperatedTermParts: [NSDictionary] -> Seperated Term Parts
    /// - Returns: NSDictionary -> Ordered Parts
    func getVariableAndNonVariablePartsFrom(seperatedTermParts: [NSDictionary]) -> NSDictionary {
        var variableParts : [String] = [];
        var nonVariableParts : [String] = [];
        
        for part in seperatedTermParts {
            var algebraicSign = "";
            var text = part["text"] as! String;
            
            if text[0].description.rangeOfCharacter(from: validationHelper.validAlgebraicSignCharacters) != nil {
                algebraicSign = text[0].description;
            }
            
            if text[0].description.rangeOfCharacter(from: validationHelper.validOperatorCharacters as CharacterSet) != nil {
                text = String(text.dropFirst());
            }
            
            if part["variable"] as! Bool == true {
                variableParts.append(algebraicSign + text);
                continue;
            }
            
            nonVariableParts.append(algebraicSign + text);
        }
        
        return ["vars": variableParts, "numeric": nonVariableParts];
    }
}

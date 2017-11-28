//
//  MathScanTests.swift
//  MathScanTests
//
//  Created by Benedikt Veith on 28.11.17.
//  Copyright © 2017 benedikt-veith. All rights reserved.
//

import XCTest

class MathScanTests: XCTestCase {
    
    let validationHelper = ValidationHelper();
    let mathCalculator = MathCalculator();
    let formatter = FormatHelper();
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testValidateText() {
        XCTAssert(validationHelper.validateText(recognizedText: "3x + 5 = 10", recognizedCharacter: [])["valid"] as! Bool == true);
        XCTAssert(validationHelper.validateText(recognizedText: "3x + 5 + = 10", recognizedCharacter: [])["valid"] as! Bool == false);
        XCTAssert(validationHelper.validateText(recognizedText: "asxf-.-vcb.,", recognizedCharacter: [])["valid"] as! Bool == false);
        XCTAssert(validationHelper.validateText(recognizedText: "3x + 5 - 10 = -10 + 5x", recognizedCharacter: [])["valid"] as! Bool == true);
        XCTAssert(validationHelper.validateText(recognizedText: "3x + 5 - 10 = -10 + 5.5x", recognizedCharacter: [])["valid"] as! Bool == true);
    }
    
    func testValidateTerm() {
        XCTAssert(validationHelper.validateTerm(term: "6+6-3x"));
        XCTAssert(validationHelper.validateTerm(term: "6+6-x3x") == false);
        XCTAssert(validationHelper.validateTerm(term: "6+6-3x3") == false);
        XCTAssert(validationHelper.validateTerm(term: "-6+6-3x"));
        XCTAssert(validationHelper.validateTerm(term: "+6+6-3x") == false);
        XCTAssert(validationHelper.validateTerm(term: "6") == false);
        XCTAssert(validationHelper.validateTerm(term: "6", fromEquation: true));
        XCTAssert(validationHelper.validateTerm(term: "6++6-3x") == false);
    }
    
    func testSeperateTerm() {
        let seperatedText = validationHelper.seperateTermInParts(term: "-3x+5-2.5");
        XCTAssert(seperatedText[0] == ["text":"-3x", "variable": true] as NSDictionary);
        XCTAssert(seperatedText[1] == ["text":"+5", "variable": false] as NSDictionary);
        XCTAssert(seperatedText[2] == ["text":"-2.5", "variable": false] as NSDictionary);
    }
    
    func testCalculateTerm() {
        var result = mathCalculator.calculateTerm(seperatedTermParts: ["3", "-5", "+3"]);
        XCTAssert(result == ["-2.0", "+3"]);
        
        result = mathCalculator.calculateTerm(seperatedTermParts: ["x", "+2x", "-3x"], variable: "x");
        XCTAssert(result == ["+3.0x", "-3x"]);
    }
    
    func testSolveEquation() {
        XCTAssert(mathCalculator.solveEquation(text: "5-5+8+3+7-9") == ["text": "+9.0"]);
        XCTAssert(mathCalculator.solveEquation(text: "3x+3-5x-6+8") == ["text": "-2.0x+5.0"]);
        XCTAssert(mathCalculator.solveEquation(text: "3x-15+2x-9=x+7-3+5") == ["text": "+x=+8.25"]);
        XCTAssert((mathCalculator.solveEquation(text: "5x+4x-3x+3=4+4+6x+2") as NSDictionary)["isEqual"] as! Bool == false);
    }
    
    func testCancelTermWithNumber() {
        XCTAssert(mathCalculator.cancelTermWithNumber(term: "4+2x+8-4x", number: "4") == "+1.0+0.5x+2.0-x");
        XCTAssert(mathCalculator.cancelTermWithNumber(term: "4+2x+8+4x", number: "4") == "+1.0+0.5x+2.0+x");
    }
    
    func testSolveEquationToVar() {
        XCTAssert(mathCalculator.solveEquationToVariable(termsFromEquationArray: ["3x+5-3", "2x+3"]) == "+x=+1.0");
    }
    
    func testCancelEquation() {
        XCTAssert(mathCalculator.cancelEquationToVariable(text: "3x=3") == "+x=+1.0");
    }
    
    func testFormatSolution() {
        XCTAssert(formatter.formatAndBeautifySolution(solution: "+x=+8.25") == "x=8.25");
        XCTAssert(formatter.formatAndBeautifySolution(solution: "+x-1.0=+8.00+2.00") == "x-1=8+2");
        XCTAssert(formatter.formatAndBeautifySolution(solution: "+1.0x=+8.25") == "x=8.25");
    }
    
}

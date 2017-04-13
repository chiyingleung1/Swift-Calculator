//
//  CalculatorViewController.swift
//  Swift Calculator
//
//  Created by Chi-Ying Leung on 4/2/17.
//  Copyright © 2017 Chi-Ying Leung. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var sequence: UILabel!
    @IBOutlet weak var memoryLbl: UILabel!
    @IBOutlet weak var errorLbl: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    private var brain = CalculatorBrain()
    
    private var graphableOperations: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memoryLbl.isHidden = true
        errorLbl.isHidden = true
        adjustButtonLayout(for: view, isPortrait: traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        adjustButtonLayout(for: view, isPortrait: newCollection.horizontalSizeClass == .compact && newCollection.verticalSizeClass == .regular)
    }
    
    @IBAction func keyPressed(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            
            if digit == "." && (textCurrentlyInDisplay.range(of: ".") != nil) { return }
            if digit == "0" && textCurrentlyInDisplay == "0" { return }
            
            display.text = textCurrentlyInDisplay + digit
            
        } else {
            display.text = (digit == "." ? "0" : "") + digit
            userIsInTheMiddleOfTyping = true
        }
        
    }
    
    // this does not belong in the Model; UI related
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = formatter.string(from: NSNumber(value: newValue))
        }
    }
    
    var variableDictionary = Dictionary<String, Double>()
    var displayResult: (result: Double?, isPending: Bool, description: String, error: String?) = (nil, false, "", nil) {
        didSet {
            displayValue = displayResult.result ?? 0
            sequence.text = displayResult.description != "" ? displayResult.description + (displayResult.isPending ? " ..." : " =") : ""
            if let mValue = variableDictionary["M"] {
                memoryLbl.isHidden = false
                memoryLbl.text = "M:" + formatter.string(from: NSNumber(value: mValue))!
            }
            if let error = displayResult.error {
                errorLbl.isHidden = false
                errorLbl.text = error
            }
        }
    }
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        if let mathSymbol = sender.currentTitle {
            brain.performOperation(mathSymbol)
        }
        
        displayResult = brain.evaluate(using: variableDictionary)
    }
    
    // ->M button pressed
    @IBAction func setM(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        let symbol = String(sender.currentTitle!.characters.dropFirst())
        variableDictionary[symbol] = displayValue
        displayResult = brain.evaluate(using: variableDictionary)
    }
    
    // M button pressed
    @IBAction func pushM(_ sender: UIButton) {
        brain.setOperand(variable: sender.currentTitle!)
        displayResult = brain.evaluate(using: variableDictionary)
    }
    
    @IBAction func clearPressed(_ sender: UIButton) {
        // clear the UI
        displayValue = 0
        sequence.text = " "
        userIsInTheMiddleOfTyping = false
        
        // clear the Model
        brain = CalculatorBrain()
        
        // clear memory
        variableDictionary = [:]
        memoryLbl.isHidden = true
        errorLbl.isHidden = true
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if var text = display.text {
                text.remove(at: text.index(before: text.endIndex))
                display.text = text
            }
        } else {
            brain.undoLast()
            displayResult = brain.evaluate(using: variableDictionary)
        }
    }
    
    private func adjustButtonLayout(for view: UIView, isPortrait: Bool) {
        for subview in view.subviews {
            if subview.tag == 1 {
                subview.isHidden = isPortrait
            }
            if let stack = subview as? UIStackView {
                adjustButtonLayout(for: stack, isPortrait: isPortrait)
            }
        }
    }
    
    @IBAction func graphPressed(_ sender: UIButton) {
        displayResult = brain.evaluate(using: variableDictionary)
        print("display result: \(displayResult)")
        
    }
    
    
}

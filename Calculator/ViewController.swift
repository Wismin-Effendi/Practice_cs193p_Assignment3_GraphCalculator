//
//  ViewController.swift
//  Calculator
//
//  Created by Wismin Effendi on 6/14/17.
//  Copyright © 2017 iShinobi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var decimalSeparator: UIButton!
    
    var userIsInTheMiddleOfTyping = false
    
    private var brain = CalculatorBrain()
    private var numberFormatter = NumberFormatter()
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = numberFormatter.string(from: newValue as NSNumber)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        numberFormatter.alwaysShowsDecimalSeparator = false
        numberFormatter.maximumFractionDigits = 6
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.minimumIntegerDigits = 1
        decimalSeparator.setTitle(numberFormatter.decimalSeparator, for: .normal)
        
        brain.numberFormatter = numberFormatter
    }
    
    @IBAction func backSpace(_ sender: UIButton) {
        guard userIsInTheMiddleOfTyping else { return }
        display.text = String(display.text!.characters.dropLast())
        if display.text?.characters.count == 0 {
            displayValue = 0.0
            userIsInTheMiddleOfTyping = false
        }
    }

    @IBAction func clearAll(_ sender: UIButton) {
        brain.clear()
        displayValue = 0.0
        history.text = " "
    }
    

    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    

    @IBAction func floatingPoint(_ sender: UIButton) {
        if !userIsInTheMiddleOfTyping {
            display.text = "0" + numberFormatter.decimalSeparator
        } else if !display.text!.contains(numberFormatter.decimalSeparator) {
            display.text = display.text! + numberFormatter.decimalSeparator
        }
        userIsInTheMiddleOfTyping = true 
    }
    

    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            // if sender not any of the constant, i.e. π or e or Ran then setOperand else skip
            if let title = sender.currentTitle,
                !Set(["π", "e", "Ran"]).contains(title) {
                brain.setOperand(displayValue)
            }
            userIsInTheMiddleOfTyping = false
        }
        
        print(brain.description)
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        
        if let result = brain.result {
            displayValue = result
        }
        let postfixDescription = brain.resultIsPending ? "..." : "="
        history.text = brain.description + postfixDescription
    }
    
    

}


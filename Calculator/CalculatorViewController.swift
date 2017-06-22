//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by Wismin Effendi on 6/14/17.
//  Copyright © 2017 iShinobi. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var decimalSeparator: UIButton!
    @IBOutlet weak var memoryKey: UIButton!
    @IBOutlet weak var backSpace_Undo: UIButton!
    @IBOutlet weak var graphBarButtonItem: UIBarButtonItem!
    
    
    var userIsInTheMiddleOfTyping = false {
        didSet {
            if userIsInTheMiddleOfTyping {
                backSpace_Undo.setTitle("⬅️", for: .normal)
            } else {
                backSpace_Undo.setTitle("✘", for: .normal)
            }
        }
    }
    
    private var brain = CalculatorBrain()
    
    private weak var numberFormatter: NumberFormatter! = CalculatorBrain.DoubleToString.numberFormatter
    
    var displayValue: Double {
        get {
            guard let valueString = display.text else { return 0.0 }
            let value = numberFormatter.number(from: valueString)
            return Double(value ?? 0)
        }
        set {
            display.text = numberFormatter.string(from: newValue as NSNumber)
            brain.saveState(using: Keys.stateOfCalculator)
        }
    }
    
    // stores dictionary containing variables. 
    // Calculator sets just one variable, but to anticipate future use..
    private var variables: [String: Double] {
        get {
            if let storedVariables = UserDefaults.standard.dictionary(forKey: Keys.variables) {
                var variables: [String: Double] = [:]
                for (key, value) in storedVariables {
                    variables[key] = (value as? Double) ?? 0
                }
                return variables
            } else {
                return [:]
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.variables)
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
        guard userIsInTheMiddleOfTyping else {
            // acting as Undo button
            undoTapped()
            return
        }
        // acting as backspace button
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
        memoryKey.setTitle("M", for: .normal)
    }
    
    
    @IBAction func onMemory(_ sender: UIButton) {
        if let key = sender.currentTitle {
            if key == "→M" {
                let variables = ["M": displayValue]
                memoryKey.setTitle(display.text!, for: .normal)
                evaluateExpression(using: variables)
            } else {
                brain.setOperand(variable: "M")
                evaluateExpression()
            }
        }
    }

    private func undoTapped() {
        _ = brain.undo()
        evaluateExpression()
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
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        evaluateExpression()
    }
    

    private func evaluateExpression(using variables: Dictionary<String,Double>? = nil) {
        let evaluation = brain.evaluate(using: variables)
        if let result = evaluation.result {
            displayValue = result
        }
        userIsInTheMiddleOfTyping = false
        let postfixDescription = evaluation.isPending ? "..." : "="
        history.text = evaluation.description + postfixDescription
        graphBarButtonItem.tintColor = evaluation.isPending ? UIColor.gray : UIColor.blue
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return !brain.evaluate().isPending
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        brain.saveState(using: Keys.stateOfGraphViewVC)
    }

}

extension CalculatorViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        
        return true
    }
}

extension CalculatorViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = traitCollection.verticalSizeClass == .compact
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        navigationController?.navigationBar.isHidden = traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular
    }
}



struct Keys {
    static let stateOfGraphViewVC = "GraphViewControllerState"
    static let stateOfCalculator = "CalculatorState"
    static let variables = "CalculatorVariables"
    static let segueToGraphVC = "segueToGraphVC"
}

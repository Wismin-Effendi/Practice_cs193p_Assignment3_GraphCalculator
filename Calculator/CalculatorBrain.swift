//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Wismin Effendi on 6/14/17.
//  Copyright © 2017 iShinobi. All rights reserved.
//

import Foundation


struct CalculatorBrain {
    
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    var resultIsPending: Bool {
        return pendingBinaryOperation != nil
    }
    
    mutating func setOperand(_ operand: Double) {
        if !resultIsPending {
            clear()
        }
        accumulator = operand
        descriptions.append(formattedAccumulator!)
    }
    
    mutating func performOperation(_ symbol: String) {
        guard let operation = operations[symbol]  else { return }
        switch operation {
        case .constant(let value):
            accumulator = value
            descriptions.append(symbol)
        case .unaryOperation(let function):
            if let operand = accumulator {
                if resultIsPending {
                    let lastOperand = descriptions.last!
                    descriptions = [String](descriptions.dropLast()) + [symbol + "(" + lastOperand + ")"]
                } else {
                    descriptions = [symbol + "("] + descriptions + [")"]
                }
                accumulator = function(operand)
            }
        case .binaryOperation(let function):
            if resultIsPending {
                performPendingBinaryOperation()
            }
            if accumulator != nil {
                pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                accumulator = nil
                descriptions.append(symbol)
            }
        case .noArgumentOperation(let function):
            accumulator = function()
            descriptions.append(symbol)
        case .equals:
            performPendingBinaryOperation()
        }
    }
    
    mutating func clear() {
        accumulator = nil
        pendingBinaryOperation = nil
        descriptions = []
    }
    
    weak var numberFormatter: NumberFormatter?
    
    var description: String {
        var returnString: String = ""
        for element in descriptions {
            returnString += element
        }
        return returnString
    }
    
    
    // MARK: - Private properties and methods

    private var descriptions: [String] = []
    private var accumulator: Double?

    private var formattedAccumulator: String? {
        if let number = accumulator {
            return numberFormatter?.string(from: number as NSNumber) ?? String(number)
        } else {
            return nil
        }
    }
    
    private enum Operation {
        case constant(Double)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double,Double) -> Double)
        case noArgumentOperation(()-> Double)
        case equals
    }
    
    private var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "1/x" : Operation.unaryOperation({ 1/$0 }),
        "%": Operation.unaryOperation({ $0/100 }),
        "cos" : Operation.unaryOperation(cos),
        "sin": Operation.unaryOperation(sin),
        "tan": Operation.unaryOperation(tan),
        "Ran": Operation.noArgumentOperation( { Double(drand48()) }),
        "±" : Operation.unaryOperation({ -$0 }),
        "x": Operation.binaryOperation(*),
        "÷": Operation.binaryOperation(/),
        "+": Operation.binaryOperation(+),
        "-": Operation.binaryOperation(-),
        "=": Operation.equals
    ]

    
    private mutating func performPendingBinaryOperation() {
        guard pendingBinaryOperation != nil && accumulator != nil  else { return }
        accumulator = pendingBinaryOperation!.perform(with: accumulator!)
        pendingBinaryOperation = nil
    }
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    private struct PendingBinaryOperation {
        let function: (Double,Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    

}

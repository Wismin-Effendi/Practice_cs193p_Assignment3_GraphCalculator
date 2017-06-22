//
//  GraphViewController.swift
//  Calculator
//
//  Created by Wismin Effendi on 6/22/17.
//  Copyright © 2017 iShinobi. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func graphView(valueYforX x: CGFloat) -> CGFloat
}

class GraphViewController: UIViewController, GraphViewDataSource {

    
    // delegate for GraphViewDataSource
    func graphView(valueYforX x: CGFloat) -> CGFloat {
        let evaluation = brain.evaluate(using: ["M": Double(x)]).result
        return CGFloat(evaluation ?? 0)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        graphView.boundsBeforeTransitionToSize = graphView.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = brain.evaluate().description
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
        navigationItem.leftItemsSupplementBackButton = true
    }


    // MARK: - Private 
    // Need to be lazy to anticipate prepareForSegue from initiating VC
    private lazy var brain: CalculatorBrain = {
        var calculatorBrain = CalculatorBrain()
        calculatorBrain.loadState(using: Keys.stateOfGraphViewVC)
        return calculatorBrain
    }()
    
    @IBOutlet private weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            setupGestureRecognizers()
            graphView.restoreData()
        }
    }
    
    private func setupGestureRecognizers() {
        graphView.addGestureRecognizer(
            UIPinchGestureRecognizer(target: graphView,
                                     action: #selector(graphView.zoom(recognizer:))))
        graphView.addGestureRecognizer(
            UIPanGestureRecognizer(target: graphView,
                                   action: #selector(graphView.pan(recognizer:))))
        graphView.addGestureRecognizer(
            UITapGestureRecognizer(target: graphView,
                                   action: #selector(graphView.setOrigin(recognizer:))))
    }

}

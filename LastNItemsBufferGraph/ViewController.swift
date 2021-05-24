//
//  ViewController.swift
//  LastNItemsBufferGraph
//
//  Created by Duncan Champney on 5/23/21.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var graphView: GraphView!

    @IBOutlet var resetButton: UIButton!
    weak var timer: Timer?
    let stepDuration = 0.05
    var buffer = LastNItemsBuffer<CGFloat>.init(count: 80)

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        buffer.forceToValue(0.0)
        graphView.points = buffer
    }
    @IBAction func handleResetButton(_ sender: UIButton) {
        graphView.reset()
    }
    @IBAction func handleShowPointsSwitch(_ theSwitch: UISwitch) {
        graphView.drawPoints = theSwitch.isOn
    }
    
    @IBAction func handleDrawBargraphSwitch(_ sender: UISwitch) {
        graphView.drawBarGraph = sender.isOn
    }
    
    @IBAction func handleAnimateSwitch(_ theSwitch: UISwitch) {
        resetButton.isEnabled = !theSwitch.isOn
        var value = CGFloat.random(in: self.graphView.minValue...self.graphView.maxValue)
        if theSwitch.isOn {
            timer = Timer.scheduledTimer(withTimeInterval: stepDuration
                                         , repeats: true) { (timer) in
                value = CGFloat.random(in: self.graphView.minValue * 0.75...self.graphView.maxValue * 0.75)
                self.graphView.animateNewValue(value, duration: self.stepDuration)
            }
        } else {
            timer?.invalidate()
        }
    }
}


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
    let stepDuration = 0.2
    var value = Character("A").asciiValue!
    var buffer = LastNItemsBuffer<CGFloat>.init(count: 20)

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
    @IBAction func handleAnimateSwitch(_ theSwitch: UISwitch) {
        resetButton.isEnabled = !theSwitch.isOn
        if theSwitch.isOn {
            timer = Timer.scheduledTimer(withTimeInterval: stepDuration
                                         , repeats: true) { (timer) in
                let newValue = CGFloat.random(in: self.graphView.minValue...self.graphView.maxValue)
                self.graphView.animateNewValue(newValue, duration: self.stepDuration)
            }
        } else {
            timer?.invalidate()
        }
    }
}


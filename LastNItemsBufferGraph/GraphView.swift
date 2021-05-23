//
//  GraphView.swift
//  LastNItemsBufferGraph
//
//  Created by Duncan Champney on 5/23/21.
//

import UIKit

class GraphView: UIView {

    var maxValue: CGFloat = 50
    var minValue: CGFloat = -50

    var points: LastNItemsBuffer<CGFloat>? {
        didSet {
            guard let layer = self.layer as? CAShapeLayer else { return }
            if oldValue == nil {
                layer.path = buildPath().path
            }
        }
    }

    static override var layerClass: AnyClass {
        return CAShapeLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        doInitSetup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        doInitSetup()
    }

    func doInitSetup() {
        guard let layer = self.layer as? CAShapeLayer else { return }
        layer.strokeColor = UIColor.black.cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 1
    }

    public func reset() {
        guard let layer = self.layer as? CAShapeLayer else { return }
        points?.forceToValue(0)
        layer.path = buildPath().path
    }

    public func animateNewValue(_ value: CGFloat, duration: Double = 0.0) {
        guard let layer = self.layer as? CAShapeLayer else { return }
        let oldPathInfo = buildPath(plusValue: value) // Create a path with the old path info plus the new point

        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = duration

        // Start the animation with the old path (Which now has an extra point "off screen" to the right)
        animation.fromValue = oldPathInfo.path

        //Animate to a new version of the path, shifted to the left by 1 step width
        var transform = CGAffineTransform(translationX: -oldPathInfo.stepWidth, y: 0)
        animation.toValue = oldPathInfo.path.copy(using: &transform)

        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        layer.add(animation, forKey: nil)

        // Update the array of points with the new point
        points?.write(value)

        // After a brief pause to let the animation begin, install the path for the new points.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            layer.path = self.buildPath().path
        }
    }
/**
     Build a path from our points array, plus an optional extra value (which we will animateion
     */
    private func buildPath(plusValue: CGFloat? = nil) -> (path: CGPath, stepWidth: CGFloat) {
        guard let points = points else {
            (layer as? CAShapeLayer)?.path = nil
            return (CGMutablePath(), 0)
        }
        let graphBounds = bounds.insetBy(dx: 0, dy: 6)
        let stepWidth = graphBounds.width / (CGFloat(points.count) - 1)
        let range = minValue - maxValue
        let stepHeight = graphBounds.height  / range

        func xForIndex(_ index: Int) -> CGFloat {
            return CGFloat(index) * stepWidth + graphBounds.origin.x
        }

        func yForvalue(_ value: CGFloat) -> CGFloat {
            return graphBounds.height / 2 + value * stepHeight + graphBounds.origin.y
        }

        let path = CGMutablePath()
        for (index, value) in points.lastNItems().enumerated() {
            let x = xForIndex(index)
            let y = yForvalue(value)
            let newPoint = CGPoint(x: x, y: y)
            if index == 0 {
                path.move(to: newPoint)
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        if let extraValue = plusValue {
            let x = xForIndex(points.count)
            let y = yForvalue(extraValue)
            path.addLine(to: CGPoint(x: x, y: y))
        }
        return (path, stepWidth)
    }
}

//
//  GraphView.swift
//  LastNItemsBufferGraph
//
//  Created by Duncan Champney on 5/23/21.
//

import UIKit

class GraphView: UIView {

    public var maxValue: CGFloat = 50
    public var minValue: CGFloat = -50

    public var drawBarGraph = true {
        didSet {
            guard let layer = self.layer as? CAShapeLayer else { return }
            layer.path = self.buildPath().path
        }
    }
    public var drawPoints: Bool = false {
        didSet {
            guard let layer = self.layer as? CAShapeLayer else { return }
            layer.path = self.buildPath().path
        }
    }

    public var points: LastNItemsBuffer<CGFloat>? {
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
        layer.strokeColor = UIColor(red: 0, green: 0, blue: 0.5, alpha: 1).cgColor
        layer.fillColor = UIColor.clear.cgColor
        layer.lineWidth = 2
        layer.lineCap = .round

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

        func pointsForIndex(_ index: Int, value: CGFloat) -> (top: CGPoint, bottom: CGPoint) {
            let top = graphBounds.height / 2 + abs(value) * stepHeight + graphBounds.origin.y
            let bottom = graphBounds.height / 2 - abs(value) * stepHeight + graphBounds.origin.y
            let x = CGFloat(index) * stepWidth + graphBounds.origin.x
            return (CGPoint(x: x, y: top), CGPoint(x: x, y: bottom))
        }
        func xForIndex(_ index: Int) -> CGFloat {
            return CGFloat(index) * stepWidth + graphBounds.origin.x
        }

        func yForvalue(_ value: CGFloat) -> CGFloat {
            return graphBounds.height / 2 + value * stepHeight + graphBounds.origin.y
        }
        let path = CGMutablePath()
        if drawBarGraph {
            for (index, value) in points.lastNItems().enumerated() {
                let points = pointsForIndex(index, value: value)
                path.move(to: points.top)
                path.addLine(to: points.bottom)
            }
            if let extraValue = plusValue {
                let points = pointsForIndex(points.count, value: extraValue)
                path.move(to: points.top)
                path.addLine(to: points.bottom)
            }
        } else {
            for (index, value) in points.lastNItems().enumerated() {
                let x = xForIndex(index)
                let y = yForvalue(value)
                let newPoint = CGPoint(x: x, y: y)
                if index == 0 {
                    path.move(to: newPoint)
                } else {
                    path.addLine(to: newPoint)
                    if drawPoints {
                        let rect = CGRect(x: x, y: y, width: 0, height: 0).insetBy(dx: -2, dy: -2)
                        path.addRect(rect)
                        path.move(to: CGPoint(x: x, y: y))
                    }
                }
            }
            if let extraValue = plusValue {
                let x = xForIndex(points.count)
                let y = yForvalue(extraValue)
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        return (path, stepWidth)
    }
}

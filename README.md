# LastNItemsBufferGraph

This project demonstrates how to animate a graph of the most recent set of points from a stream of data.

It uses a simple struct, `LastNItemsBuffer`, which lets you append values to an array and keeps the last N values.

The program defines a class, `GraphView`, which has a `LastNItemsBuffer` of points.
The `GraphView` implements a method `animateNewValue(_:duration:)` which will animate a new point onto the graph. 

Internally, the `GraphView` uses a `CAShapeLayer` to render the graph. When you add a new point, it appends the point to the previous path, then animates shifting the graph path to the left to reveal the new value. When the animation is complete it installs the updated graph path into the `GraphView`'s `CAShapeLayer`.

The animation looks like this:

![Graph animation](Graph animation.gif)